require_relative '../test_helper'

class NewsletterTest < ActiveSupport::TestCase
  context "a newsletter" do
    setup do
      @nonprofit = FactoryGirl.create(:current_nonprofit)
      @newsletter = @nonprofit.newsletter
    end

    context "with donors, gifts, and subscribers" do
      setup do
        @donor = FactoryGirl.create(:stripe_donor)
        @active_cancelled_donor = FactoryGirl.create(:active_cancelled_donor)
        @inactive_cancelled_donor = FactoryGirl.create(:inactive_cancelled_donor)
        @subscriber = FactoryGirl.create(:subscriber)
        @cancelled_subscriber = FactoryGirl.create(:unsubscribed_subscriber)
      end

      context "sending donor newsletter" do
        setup do
          NewsletterMailer.expects(:batched_daily).once.
            with("donor", @newsletter.id, {
              @donor.subscriber.email => {
                "name" => @donor.subscriber.first_name,
                "guid" => @donor.subscriber.guid,
                "auth_token" => @donor.subscriber.auth_token
              },
              @active_cancelled_donor.subscriber.email => {
                "name" => @active_cancelled_donor.subscriber.first_name,
                "guid" => @active_cancelled_donor.subscriber.guid,
                "auth_token" => @active_cancelled_donor.subscriber.auth_token
              }
            })
          @newsletter.send_donor!
        end

        should_change "emails", by: 2 do @newsletter.emails.count end

        should_change "donor's emails", by: 1 do @donor.subscriber.emails.count end
        should_change "active_cancelled_donor's emails", by: 1 do @active_cancelled_donor.subscriber.emails.count end
        should_not_change "inactive_cancelled_donor's emails" do @inactive_cancelled_donor.subscriber.emails.count end
        should_not_change "subscriber's emails" do @subscriber.emails.count end
        should_not_change "cancelled_subscriber's emails" do @cancelled_subscriber.emails.count end

        should_change "donor_generated", from: nil do @newsletter.donor_generated end
        should_change "donors sent timestamp", from: nil do @newsletter.donors_sent_at end
      end

      context "sending subscriber newsletter" do
        setup do
          NewsletterMailer.expects(:batched_daily).once.
            with("subscriber", @newsletter.id, {
              @subscriber.email => {
                "name" => @subscriber.first_name,
                "guid" => @subscriber.guid,
                "auth_token" => @subscriber.auth_token
              },
              @inactive_cancelled_donor.subscriber.email => {
                "name" => @inactive_cancelled_donor.subscriber.first_name,
                "guid" => @inactive_cancelled_donor.subscriber.guid,
                "auth_token" => @inactive_cancelled_donor.subscriber.auth_token
              }
            })
          @newsletter.send_subscriber!
        end

        should_change "emails", by: 2 do @newsletter.emails.count end

        should_not_change "donor's emails" do @donor.subscriber.emails(true).count end
        should_not_change "active_cancelled_donor's emails" do @active_cancelled_donor.subscriber.emails(true).count end
        should_change "inactive_cancelled_donor's emails", by: 1 do @inactive_cancelled_donor.subscriber.emails(true).count end
        should_change "subscriber's emails", by: 1 do @subscriber.emails(true).count end
        should_not_change "cancelled_subscriber's emails" do @cancelled_subscriber.emails(true).count end

        should_change "subscriber sent timestamp", from: nil do @newsletter.subscribers_sent_at end
      end
    end

    context "after being sent" do
      setup do
        # TODO factory?
        @newsletter.update_columns(
          subscriber_generated: @newsletter.subscriber_generate,
          donor_generated: @newsletter.donor_generate,
          subscribers_sent_at:  Time.now,
          donors_sent_at: Time.now
        )
      end

      context "resetting" do
        setup { @newsletter.reset! }
        should_change "sent?", from: true, to: false do @newsletter.sent? end
      end
    end
  end
end
