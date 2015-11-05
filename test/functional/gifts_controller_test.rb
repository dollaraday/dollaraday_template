require_relative '../test_helper'

class GiftsControllerTest < ActionController::TestCase
  context "new gift" do
    setup { get :new }

    should respond_with :success
    should "assign new gift" do assert assigns(:gift).new_record? end
    should "assign new donor" do assert assigns(:gift).donor.new_record? end
  end

  context "thanks page" do
    setup { session[:thanks] = true; get :thanks }
    should render_template(:thanks)
    should_change "session[:thanks]", to: nil do session[:thanks] end
  end

  context "new gift donor" do
    setup { get :new }

    should respond_with :success
    should "assign new donor" do assert assigns(:donor).new_record? end
    should "assign new gift" do assert assigns(:donor).gift.new_record? end
  end

  context "a random visitor" do
    context "thanks page" do
      setup { get :thanks }
      should redirect_to("home") { root_url }
    end
  end

  context "a subscriber, and a donor" do
    setup do
      @subscriber = FactoryGirl.create(:subscriber)
      @donor = FactoryGirl.create(:stripe_donor)
    end

    context "checking for subscriber's existence" do
      setup { get :exists, email: @subscriber.email, format: :json }

      should "render false" do
        expected = {success: false}
        assert_equal expected.to_json, @response.body
      end
    end

    context "checking for donor's existence" do
      setup { get :exists, email: @donor.subscriber.email, format: :json }

      should "render true + message" do
        expected = {success: true, message: "Woops, that person is already a donor!"}
        assert_equal expected.to_json, @response.body
      end
    end
  end

  context "creating a gift" do
    setup do
      @donor_params = {
        add_fee: "1",
        gift_attributes: {
          months_remaining: 3,
          message: "Hey Bob, this is interesting, check it out!"
        },
        subscriber_attributes: {
          name: "Bob Giftee",          # Gift#recipient_name
          email: "giftee@loblaw.com"   # Gift#recipient_email
        },
        card_attributes: {
          name: "Bob Giver",         # Gift#giver_name
          email: "giver@loblaw.com"  # Gift#giver_email
        }
      }
    end

    context "with valid params" do
      setup do
        post :create,
          donor: @donor_params,
          stripeToken: generate_stripe_card_token
      end

      should_change "gifts", by: 1 do Gift.count end
      should_change "donors", by: 1 do Donor.count end
      should_change "cards", by: 1 do DonorCard.count end
      should_change "subscribers", by: 2 do Subscriber.count end # gift.donor.subscriber + gift.giver_subscriber
      should redirect_to("thanks page") { thanks_gifts_url }
      should "set gift values correctly" do
        gift = Gift.last
        assert_equal "Bob Giftee", gift.recipient_name
        assert_equal "giftee@loblaw.com", gift.recipient_email
        assert_equal "Bob Giver", gift.giver_name
        assert_equal "giver@loblaw.com", gift.giver_email
      end
    end

    context "while the recipient is already subscribing" do
      setup { @existing_subscriber = FactoryGirl.create(:subscriber, email: "giftee@loblaw.com") }

      context "using their email as recipient email" do
        setup do
          Donor.any_instance.expects(:create_cof).never
          @donor_params[:subscriber_attributes][:email] = @existing_subscriber.email
          post :create,
            donor: @donor_params,
            stripeToken: generate_stripe_card_token
        end

        should_change "gifts", by: 1 do Gift.count end
        should_change "donors", by: 1 do Donor.count end
        should_change "cards", by: 1 do DonorCard.count end
        should_change "subscribers", by: 1 do Subscriber.count end # gift.giver_subscriber
        should redirect_to("thanks page") { thanks_gifts_url }
        should "set gift values correctly" do
          gift = Gift.last
          assert_equal "Bob Giftee", gift.recipient_name
          assert_equal "giftee@loblaw.com", gift.recipient_email
          assert_equal "Bob Giver", gift.giver_name
          assert_equal "giver@loblaw.com", gift.giver_email
        end
      end
    end

    context "while the recipient is already donating" do
      setup { @existing_donor = FactoryGirl.create(:stripe_donor) }

      context "using their email as recipient email" do
        setup do
          Donor.any_instance.expects(:create_cof).never
          @donor_params[:subscriber_attributes][:email] = @existing_donor.subscriber.email
          post :create,
            donor: @donor_params,
            stripeToken: generate_stripe_card_token
        end

        should_not_change "donors" do Donor.count end
        should_not_change "gifts" do Gift.count end
        should_not_change "donor_cards" do DonorCard.count end
        should_not_change "subscribers" do Subscriber.count end
        should render_template(:new)
        should "render errors" do
          assert_select ".field_with_errors"
        end
      end
    end

    context "with invalid recipient email" do
      setup do
        Donor.any_instance.expects(:create_cof).never
        @donor_params[:subscriber_attributes][:email] = "blah"
        post :create,
          donor: @donor_params,
          stripeToken: generate_stripe_card_token
      end

      should_not_change "donors" do Donor.count end
      should_not_change "gifts" do Gift.count end
      should_not_change "donor_cards" do DonorCard.count end
      should_not_change "subscribers" do Subscriber.count end
      should render_template(:new)
      should "render errors" do
        assert_select ".field_with_errors"
      end
    end

    context "with invalid giver email" do
      setup do
         Donor.any_instance.expects(:create_cof).never
         @donor_params[:card_attributes][:email] = "blah"
         post :create,
          donor: @donor_params,
          stripeToken: generate_stripe_card_token
      end

      should_not_change "donors" do Donor.count end
      should_not_change "gifts" do Gift.count end
      should_not_change "donor_cards" do DonorCard.count end
      should_not_change "subscribers" do Subscriber.count end
      should render_template(:new)
      should "render errors" do
        assert_select ".field_with_errors"
      end
    end
  end


  context "an expiring gift" do
    setup do
      @gift = FactoryGirl.create(:expiring_gift)
    end

    context "visiting the convert page" do
      setup do
        get :convert, guid: @gift, auth: @gift.donor.subscriber.auth_token
      end

      should respond_with :success
    end

    context "converting" do
      setup do
        @donor_params = {
          card_attributes: {
            name: @gift.donor.subscriber.name,
            email: @gift.donor.subscriber.email
          }
        }
      end

      context "with valid params" do
        setup do
          post :update,
            guid: @gift,
            auth: @gift.donor.subscriber.auth_token,
            donor: @donor_params,
            stripeToken: generate_stripe_card_token
        end

        should_change "donor cards", by: 1 do @gift.donor.cards(true).count end
        should_change "donor card" do @gift.donor.card(true) end
        should_change "converted_to_recipient?", to: true do @gift.reload.converted_to_recipient? end
        should redirect_to("homepage") { root_url }
      end

      context "with invalid email" do
        setup do
          @donor_params[:card_attributes][:email] = "blah"
          post :update,
            guid: @gift,
            auth: @gift.donor.subscriber.auth_token,
            donor: @donor_params,
            stripeToken: generate_stripe_card_token
        end

        should_not_change "donor_cards" do DonorCard.count end
        should_not_change "subscribers" do Subscriber.count end
        should render_template(:convert)
        should "render errors" do
          assert_select ".field_with_errors"
        end
      end

    end
  end

end
