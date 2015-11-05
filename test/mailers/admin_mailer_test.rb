require_relative '../test_helper'

class AdminMailerTest < ActionMailer::TestCase
  setup do
    ActionMailer::Base.deliveries = []
  end

  context "delayed job report" do
    context "with nothing errored or backed up" do
      setup do
        AdminMailer.delayed_jobs.deliver
      end
      should_deliver
    end

    context "with errored and backed up jobs" do
      setup do
        Delayed::Job.create.tap{|dj|
          dj.last_error = 'Foo'
          dj.handler = 'Foo'
          dj.save
        }
        Delayed::Job.create.tap{|dj|
          dj.run_at = 30.minutes.ago
          dj.handler = 'Bar'
          dj.save
        }

        AdminMailer.delayed_jobs.deliver
      end
      should_deliver
    end
  end
end

