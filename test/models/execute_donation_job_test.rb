require_relative '../test_helper'

class ExecuteDonationJobTest < ActiveSupport::TestCase
  context "a locked executing donation" do
    subject { FactoryGirl.create(:scheduled_donation, locked_at: Time.now) }

    context "executing" do
      setup do
        Donation.any_instance.expects(:execute!).once
        ExecuteDonationJob.new(subject.id).perform
      end

      should_not_change "lock" do subject.locked_at end
    end
  end

  context "a scheduled donation that's not locked" do
    subject { FactoryGirl.create(:scheduled_donation) }

    context "executing" do
      setup do
        Donation.any_instance.expects(:execute!).never
        ExecuteDonationJob.new(subject.id).perform
      end

      should_not_change "lock" do subject.locked_at end
    end
  end

  context "an executed donation" do
    subject { FactoryGirl.create(:executed_donation) }

    context "executing" do
      setup do
        Donation.any_instance.expects(:execute!).never
        ExecuteDonationJob.new(subject.id).perform
      end

      should_not_change "lock" do subject.locked_at end
    end
  end
end
