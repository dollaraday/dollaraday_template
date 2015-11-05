require_relative '../test_helper'

class GiftTest < ActiveSupport::TestCase
  context "a gift" do
    subject { FactoryGirl.create(:gift) }

    should have_one(:donor)
    should validate_presence_of(:donor)
    should validate_presence_of(:message)
    should validate_presence_of(:giver_subscriber)

    should "not be expiring in 5 days" do
      refute subject.in?(Gift.expiring_within_days(5))
    end
    context "sending out reminders" do
      setup { Gift.send_expiration_reminders }
      should_not_delay_job "SendGiftRecipientReminderEmailJob"
    end

    context "5 days before expiring" do
      setup { Timecop.freeze(subject.finish_on - 5) }
      should "be expiring in 5 days" do
        assert subject.in?(Gift.expiring_within_days(5))
      end

      context "sending out reminders" do
        setup { Gift.send_expiration_reminders }
        should_delay_job "SendGiftRecipientReminderEmailJob"
      end
    end

    context "with nil months_remaining (infinite)" do
      setup { subject.months_remaining = nil }

      should "be valid" do assert subject.valid? end
      should "be active" do assert subject.active? end
      should "infinite" do assert subject.infinite? end

      context "decrementing" do
        setup { subject.decrement! }
        should_not_change "months_remaining" do subject.months_remaining end
      end
    end

    context "with 0 months_remaining (expired)" do
      setup { subject.months_remaining = 0 }

      should "be valid" do assert subject.valid? end
      should "not inactive" do assert !subject.inactive? end
      should "not be infinite" do refute subject.infinite? end
    end

    context "with 3 months_remaining" do
      setup { subject.months_remaining = 3 }

      should "be valid" do assert subject.valid? end
      should "be active" do assert subject.active? end
      should "not be infinite" do refute subject.infinite? end

      context "decrementing" do
        setup { subject.decrement! }
        should_change "months_remaining", by: -1 do subject.months_remaining end
      end
    end

    context "with 4 months_remaining" do
      setup { subject.months_remaining = 4 }

      should "not be valid" do refute subject.valid? end
      should "be active" do assert subject.active? end
      should "not be infinite" do refute subject.infinite? end
    end
  end


  context "a new gift" do
    subject { FactoryGirl.build(:gift) }

    context "saving" do
      setup { subject.save! }

      should "preprocess" do
        subject.reload

        assert_equal subject.months_remaining, subject.original_months_remaining
        assert_equal subject.donor.card.email, subject.giver_email
        assert_equal subject.donor.card.name, subject.giver_name
        assert_equal subject.donor.subscriber.email, subject.recipient_email
        assert_equal subject.donor.subscriber.name, subject.recipient_name
        assert_equal Date.today, subject.start_on
        assert_equal Date.today + 30, subject.finish_on

        # New subscriber
        assert_equal subject.giver_email, subject.giver_subscriber.email
        assert_equal subject.giver_name, subject.giver_subscriber.name
        assert_equal Time.now.change(usec: 0), subject.giver_subscriber.unsubscribed_at.change(usec: 0)
      end
      should "be active" do assert subject.active? end
      should "not be expired" do refute subject.expired? end
      should_delay_job "SendGiftConfirmationEmailJob"
      should_change "Subscriber count", by: 2 do Subscriber.count end
      should_delay_job "SendGiftRecipientInitialJob"

      context "converting from giver to recipient" do
        setup { subject.update_attribute(:converted_to_recipient, true) }

        should_change "active?", to: false do subject.reload.active? end
      end
    end

    context "gifted by an existing subscriber" do
      setup { @existing_subscriber = FactoryGirl.create(:subscriber, email: subject.donor.card.email) }

      context "saving" do
        setup { subject.save! }

        should "preprocess" do
          subject.reload

          assert_equal subject.months_remaining, subject.original_months_remaining
          assert_equal subject.donor.card.email, subject.giver_email
          assert_equal subject.donor.card.name, subject.giver_name
          assert_equal subject.donor.subscriber.email, subject.recipient_email
          assert_equal subject.donor.subscriber.name, subject.recipient_name
          assert_equal Date.today, subject.start_on
          assert_equal Date.today + 30, subject.finish_on

          # New subscriber
          assert_equal @existing_subscriber.email, subject.giver_subscriber.email
          assert_equal @existing_subscriber.name, subject.giver_subscriber.name
          assert_nil   subject.giver_subscriber.unsubscribed_at
        end
        should "be active" do assert subject.active? end
        should "not be expired" do refute subject.expired? end
        should_delay_job "SendGiftConfirmationEmailJob"
        should_change "Subscriber count", by: 1 do Subscriber.count end
        should_change "existing subscriber's gifts", by: 1 do @existing_subscriber.given_gifts.count end

        context "converting from giver to recipient" do
          setup { subject.update_attribute(:converted_to_recipient, true) }

          should_change "active?", to: false do subject.reload.active? end
        end
      end
    end

  end

  context "an expired gift" do
    subject { FactoryGirl.create(:expiring_gift) }

    context "converting to recipient" do
      setup { subject.convert_to_recipient! }

      should_change "converted_to_recipient", to: true do subject.reload.converted_to_recipient? end
    end

    context "with a donation that expired because the gift expired" do
      setup do
        donation = FactoryGirl.create(:failed_gift_donation, donor: subject.donor, donor_card: subject.donor.card)
        Donation.any_instance.expects(:fix!).once
        subject.convert_to_recipient!
      end

      should_change "converted_to_recipient", to: true do subject.reload.converted_to_recipient? end
    end
  end

end
