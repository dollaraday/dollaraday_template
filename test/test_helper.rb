require 'simplecov'
SimpleCov.start 'rails' do
  add_group "Jobs", "app/jobs"
end

ENV["RAILS_ENV"] = "test"
require File.expand_path('../../config/environment', __FILE__)
require "rails/test_help"
require "mocha/setup"
require 'shoulda/matchers'

class ActionController::TestCase
  include Devise::TestHelpers
end

class ActiveSupport::TestCase
  setup do
    Timecop.freeze(Time.now)
    StripeMock.start

    NetworkForGood::CreditCard.stubs(:get_donor_co_fs)
    NetworkForGood::CreditCard.stubs(:get_fee)
    NetworkForGood::CreditCard.stubs(:delete_donor_cof)
    NetworkForGood::CreditCard.stubs(:npo_detail_info).returns({})
    NetworkForGood::CreditCard.stubs(:create_cof).at_least(0).returns({
      status_code: "Success",
      message: nil,
      error_details: nil,
      call_duration: "2.0000383999999998",
      donor_token: "should_be_a_donor_token",
      cof_id: "1243661"
    })
  end

  teardown do
    StripeMock.stop
    Timecop.return
  end

  def self.should_return_json(description, &block)
    before = lambda { @_before_should_not_change = self.instance_exec(&block) }
    should "return json", before: before do
      assert_equal @_before_should_not_change.to_json, response.body, "#{description} changed"
    end
  end

  def self.stripe_test_helper
    @stripe_test_helper ||= StripeMock.create_test_helper
  end

  def self.generate_stripe_card_token(card_params: {})
    card_params.merge!(last_4: '1234', exp_year: Date.today.year)
    stripe_test_helper.generate_card_token(card_params)
  end

  def generate_stripe_card_token
    self.class.generate_stripe_card_token
  end

  def last_email
    ActionMailer::Base.deliveries.last
  end

  def login_subscriber subscriber
    @controller.instance_eval "@current_subscriber = Subscriber.find_by_guid('#{subscriber.guid}')"
  end

end

module Shoulda::ChangeMacro
  def should_change(description, options = {}, &block)
    by = options.delete(:by) if options.key?(:by)
    from = options.delete(:from) if options.key?(:from)
    to = options.delete(:to) if options.key?(:to)
    stmt = "change #{description}"
    stmt << " from #{from.inspect}" if from
    stmt << " to #{to.inspect}" if to
    stmt << " by #{by.inspect}" if by

    before = lambda { @_before_should_change = self.instance_exec(&block) }
    should stmt, before: before do
      old_value = @_before_should_change
      new_value =  self.instance_exec(&block)
      assert_operator from, :===, old_value, "#{description} did not originally match #{from.inspect}" if from
      assert_not_equal old_value, new_value, "#{description} did not change" unless by == 0
      assert_operator to, :===, new_value, "#{description} was not changed to match #{to.inspect}" if to
      assert_equal old_value + by, new_value if by
    end
  end

  def should_not_change(description, &block)
    before = lambda { @_before_should_not_change = self.instance_exec(&block) }
    should "not change #{description}", before: before do
      new_value = self.instance_exec(&block)
      assert_equal @_before_should_not_change, new_value, "#{description} changed"
    end
  end

  def should_queue_email(klass, method, *args)
    test_name = "queue #{klass}.#{method}"
    test_name += " with #{args.join(', ')}" if args.present?

    should test_name, before: proc{ @_before_should_queue_email = Email.maximum(:id) } do
      assert find_email(klass, method, args, @_before_should_queue_email)
    end
  end

  def should_not_queue_email(klass, method, *args)
    test_name = "not queue #{klass}.#{method}"
    test_name += " with #{args.join(', ')}" if args.present?

    should test_name, before: proc{ @_before_should_not_queue_email = Email.maximum(:id) } do
      email = find_email(klass, method, args, @_before_should_not_queue_email)
      assert !email, email.inspect
    end
  end

  # NOTE: has a weakness from shoulda's setup: unless something resets the deliveries array
  # after every test, the "last_email" could be from a previous test case. rspec solves this
  # with lambda assertions. what's the right way with shoulda?
  def should_deliver
    should "deliver an email" do
      assert_not_nil last_email
    end
  end

  def should_deliver_to(email = nil, &block)
    raise ArgumentError unless email || block

    should "deliver to specified user" do
      email ||= instance_eval(&block).email
      assert_equal [email], last_email.to
    end
  end

  def should_deliver_from(email_str)
    should "deliver from #{email_str}" do
      assert_equal [email_str], last_email.from
    end
  end

  def last_email
    ActionMailer::Base.deliveries.last
  end

  def find_email(klass, method, args, last_id = nil)
    scope = Email.of_type(klass, method)
    scope = scope.with_args(*(args.map{|i| instance_eval(i)})) unless args.blank?
    scope.where("id > ?", last_id || 0).last
  end

end
ActiveSupport::TestCase.extend(Shoulda::ChangeMacro)

module Shoulda::DelayJobMacro
  extend ActiveSupport::Concern

  def find_job(name)
    find_jobs(name).first
  end

  def find_jobs(name)
    Delayed::Job.where("handler LIKE '%#{name}%'")
  end

  module ClassMethods
    def should_delay_job(name, options = {})
      should "delay a #{name} job", before: proc{ Delayed::Job.destroy_all } do
        job = find_job(name)
        assert job, "no #{name} job found"
      end
    end

    def should_not_delay_job(name, options = {})
      should "not delay a #{name} job", before: proc{ Delayed::Job.destroy_all } do
        assert !find_job(name)
      end
    end
  end
end
ActiveSupport::TestCase.include(Shoulda::DelayJobMacro)
