require_relative '../test_helper'

class DonorsControllerTest < ActionController::TestCase
  context "listing donors" do
    setup do
      sign_in FactoryGirl.create(:admin) # Using factory girl as an example

      @donor1 = FactoryGirl.create(:stripe_donor)
      @donor2 = FactoryGirl.create(:active_cancelled_donor)
      @donor3 = FactoryGirl.create(:inactive_cancelled_donor)

      get :index
    end

    should "fetch all active donors" do
      assert_equal [@donor1, @donor2], assigns(:donors)
    end
  end

  context "new donor" do
    setup { get :new }

    should respond_with :success
    should "assign new donor" do assert assigns(:donor).new_record? end
  end

  context "fetching state" do
    context "with a valid zip code" do
      setup { get :fetch_state_by_zip, zip: "11372", format: :json }
      should_return_json "location" do {"city" => "Jackson Heights", "state" => "NY"} end
    end

    context "with an invalid zip code" do
      setup { get :fetch_state_by_zip, zip: "abcde", format: :json }
      should_return_json "location" do {} end
    end

    context "with a valid zip code, as html" do
      should "return nothing" do
        assert_raises(ActionController::UnknownFormat) {
          get :fetch_state_by_zip, zip: "11372", format: :html
        }
      end
    end
  end

  context "a new donor" do
    setup { session[:thanks] = true }

    context "thanks page" do
      setup { get :thanks }
      should render_template(:thanks)
      # should_change "session[:thanks]", to: nil do session[:thanks] end
    end
  end

  # context "a random visitor" do
  #   context "thanks page" do
  #     setup { get :thanks }
  #     should redirect_to("home") { root_url }
  #   end
  # end

  context "creating a donor" do
    setup do
      @donor_params = {
        add_fee: "1",
        public_name: "Bob L",
        card_attributes: {
          name: "Bob Loblaw",
          email: "bob@loblaw.com"
        }
      }
    end

    context "with valid params" do
      setup do
        post :create, donor: @donor_params, stripeToken: generate_stripe_card_token
      end

      should_change "donors", by: 1 do Donor.count end
      should_change "cards", by: 1 do DonorCard.count end
      should_change "subscribers", by: 1 do Subscriber.count end
      should redirect_to("thanks page") { thanks_donors_url }
    end

    context "with invalid subscriber email" do
      setup do
         Donor.any_instance.expects(:create_cof).never
         @donor_params[:card_attributes][:email] = "blah"
         post :create, donor: @donor_params
      end

      should_not_change "donors" do Donor.count end
      should_not_change "donor_cards" do DonorCard.count end
      should_not_change "subscribers" do Subscriber.count end
      should render_template(:new)
      should "render errors" do
        assert_select ".field_with_errors"
      end
    end
  end

  context "a subscriber, a donor, an active cancelled donor, and an inactive cancelled donor" do
    setup do
      @subscriber = FactoryGirl.create(:subscriber)
      @donor = FactoryGirl.create(:stripe_donor)
      @active_cancelled_donor = FactoryGirl.create(:active_cancelled_donor)
      @inactive_cancelled_donor = FactoryGirl.create(:inactive_cancelled_donor)
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
        expected = {success: true, message: "You're already a donor. To manage your account"}
        assert_equal expected.to_json, @response.body
      end
    end

    context "checking for active cancelled donor's existence" do
      setup { get :exists, email: @active_cancelled_donor.subscriber.email, format: :json }

      should "render true + message" do
        expected = {success: true, message: "You've recently canceled. To start donating again, or otherwise manage your account,"}
        assert_equal expected.to_json, @response.body
      end
    end

    context "checking for inactive cancelled donor's existence" do
      setup { get :exists, email: @inactive_cancelled_donor.subscriber.email, format: :json }

      should "render false" do
        expected = {success: true, message: "You've recently canceled. To start donating again, or otherwise manage your account,"}
        assert_equal expected.to_json, @response.body
      end
    end
  end

  context "a failed card" do
    context "going to fix" do
      should_eventually "work"
    end

    context "fixing" do
      should_eventually "work"
    end
  end

end
