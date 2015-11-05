require_relative '../test_helper'

class SubscriberTest < ActiveSupport::TestCase
 	context "a new subscriber" do
 		subject { FactoryGirl.build(:subscriber) }

    should allow_value('test@gmail.com').for(:email)
    should_not allow_value("test@gmail").for(:email)
    should_not allow_value('').for(:email)

    should "validate uniqueness of email" do
      existing_card = FactoryGirl.create(:subscriber, email: subject.email)
      assert !subject.valid?
      assert_equal ["is already signed up!"], subject.errors[:email]
    end

 		context "saving" do
 			setup { subject.save! }

 			should_change "subscribed_at", from: nil do subject.subscribed_at end
 			should_change "guid", from: nil do subject.guid end
 			should_change "auth_token", from: nil do subject.auth_token end
      should_delay_job "SendFirstNewsletterJob"
 			should_delay_job "SetSubscriberLocationJob"
 		end
 	end

	context "a subscriber" do
		subject { FactoryGirl.create(:subscriber) }

	 	should ensure_length_of(:name).is_at_most(100)
	 	should validate_presence_of(:auth_token)
	 	should validate_presence_of(:ip_address)
	 	should validate_uniqueness_of(:auth_token)
	 	should "render guid as param"  do assert_equal subject.guid, subject.to_param end

	 	context "unsubscribing" do
	 		setup { subject.unsubscribe! }

 			should_change "unsubscribed_at" do subject.unsubscribed_at end
 			should_change "active?", to: false do subject.active? end
	 	end
	end

 	context "a cancelled subscriber" do
 		subject { FactoryGirl.create(:unsubscribed_subscriber) }

		context "resubscribing" do
 			setup { subject.resubscribe! }

 			should_change "unsubscribed_at", to: nil do subject.unsubscribed_at end
 			should_change "subscribed_at" do subject.unsubscribed_at end
 			should_delay_job "SendFirstNewsletterJob"
 			should_change "active?", to: true do subject.active? end
 		end
 	end
end
