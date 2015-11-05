require_relative '../test_helper'

class SetSubscriberLocationJobTest < ActiveSupport::TestCase
  context "a subscriber" do
    subject { FactoryGirl.create(:subscriber) }

    context "setting location in job" do
      setup do
        Subscriber.any_instance.expects(:set_location).once
        SetSubscriberLocationJob.new(subject.id).perform
      end

      # NB better way to fire this test?
      should "fire" do assert true end
    end
  end
end
