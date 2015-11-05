require_relative '../test_helper'

class SendDailySubscriberNewsletterJobTest < ActiveSupport::TestCase
  context "with a nonprofit" do
    setup { @nonprofit = FactoryGirl.create(:current_nonprofit) }

    context "sending daily subscriber newsletter" do
      setup do
        Newsletter.any_instance.expects(:send_subscriber!).once
        SendDailySubscriberNewsletterJob.new(@nonprofit.id).perform
      end

      should("execute") { assert true }
    end
  end
end
