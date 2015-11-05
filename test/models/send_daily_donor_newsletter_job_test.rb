require_relative '../test_helper'

class SendDailyDonorNewsletterJobTest < ActiveSupport::TestCase
  context "with a nonprofit" do
    setup { @nonprofit = FactoryGirl.create(:current_nonprofit) }

    context "sending daily donor newsletter" do
      setup do
        Newsletter.any_instance.expects(:send_donor!).once
        SendDailyDonorNewsletterJob.new(@nonprofit.id).perform
      end

      should("execute") { assert true }
    end
  end
end
