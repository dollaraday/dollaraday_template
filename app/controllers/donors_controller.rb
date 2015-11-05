class DonorsController < ApplicationController
  before_filter :authenticate_user!, only: :index
  before_filter :admin_required, only: :index

  before_filter :require_donor, only: [:cancel, :uncancel, :edit, :update]
  before_filter :initialize_donor, only: [:new, :create, :new_gift, :create_gift]

  respond_to :html, except: [:exists, :fetch_state_by_zip, :map]
  respond_to :json, only: [:exists, :fetch_state_by_zip, :map]

  def index
    @donors = Donor.active.order("created_at ASC")
    @subscriber = Subscriber.new
  end

  def new
    @require_stripe_js = true
    @hide_header = true
    @hide_footer = true

    if params[:email].present?
      @subscriber = Subscriber.where(email: params[:email].to_s).first_or_initialize
      @donor.subscriber = @subscriber
      @donor.build_card(email: @subscriber.email)
    end

    respond_with(@donor)
  end

  def create
    @require_stripe_js = true
    @hide_header = true
    @hide_footer = true

    @donor.attributes      = donor_params
    @donor.card.ip_address = request.ip

    @donor.card.stripe_token = params[:stripeToken] if params["stripeToken"].present?

    Donor.transaction do
      @donor.save!

      # Have the first donation execute immediately (instead of the 15-minute
      # cron interval) so it seems more immediate.
      @donor.donations.pending.first.lock_and_execute!
      session[:thanks] = @donor.subscriber.first_name
      redirect_to thanks_donors_url
    end
 rescue ActiveRecord::RecordInvalid, ActiveRecord::RecordNotSaved => e
    render :new
  end

  # "Change Billing Details"
  def edit
    @require_stripe_js = true
    @new_card = current_donor.cards.new
  end

  # TODO cleanup
  def update
    @require_stripe_js = true
    @new_card            = DonorCard.new(donor_card_params[:card_attributes])
    @new_card.ip_address = request.ip
    @new_card.is_active  = false
    @new_card.donor      = current_donor # TODO inverse_of?
    @new_card.stripe_token = params[:stripeToken]
    @new_card.stripe_email = params[:stripeEmail]
    @new_card.save!

    was_failed = current_donor.failed?

    current_donor.reload
    current_donor.cards.active.where.not(id: @new_card.id).each(&:deactivate!)
    @new_card.activate!

    # If they're fixing their card, try the failed donation again.
    if donation = current_donor.donations.failed.first
      donation.fix!
    end

    if was_failed
      flash[:notice] = "Thanks! We'll try it again now, and let you know by email."
    else
      flash[:notice] = "Thanks! We'll use this card from here on out."
    end
    redirect_to root_url
  rescue ActiveRecord::RecordInvalid => e
    render :edit
  end

  def cancel
    @creds = params[:donor_verification]

    # TODO test the @auth_method thing -- this is so users don't have to 2x auth
    #  when going to cancel via website (instead of email)
    if auth_method == :card || current_donor.card.valid_credentials?(@creds[:last_4], @creds[:exp_month], @creds[:exp_year])
      current_donor.cancel!
      render json: {success: "Thanks! Your future donations have been cancelled."}
    else
      render json: {error: "Sorry, those were not the correct credentials!"}
    end
  end

  def uncancel
    @creds = params[:donor_verification]

    # TODO test the @auth_method thing -- this is so users don't have to 2x auth
    #  when going to cancel via website (instead of email)
    if auth_method == :card || current_donor.card.valid_credentials?(@creds[:last_4], @creds[:exp_month], @creds[:exp_year])
      current_donor.uncancel!
      render json: {success: "Thanks, you've signed up to start donating again!"}
    else
      render json: {error: "Sorry, those were not the correct credentials!"}
    end
  end

  # TODO throttle this?
  def exists
    @donor = Subscriber.where(email: params[:email].to_s).first.try(:donor)

    # TODO other way for gifts here
    if @donor && (@donor.gift.nil? || @donor.gift.converted_to_recipient?)
      if @donor.active?
        if @donor.cancelled?
          msg = "You've recently canceled. To start donating again, or otherwise manage your account,"
        else
          msg = "You're already a donor. To manage your account"
        end
      else
        msg = "You've recently canceled. To start donating again, or otherwise manage your account,"
      end

      json = { success: true, message: msg }
    else
      json = { success: false }
    end

    respond_to do |format|
      format.json do
        render json: json
      end
    end
  end

  # Verify the donor's info, and pass them on to status page (?)
  def verify
    if verify_donor
      json = { success: true, location: subscriber_url(current_subscriber) }
    else
      json = { success: false, message: "We couldn't verify this account. Please check your info." }
    end

    respond_to do |format|
      format.json do
        render json: json
      end
    end
  end

  def thanks
    @hide_header = true
    @hide_footer = true

    @name = session['thanks']
    redirect_to root_url unless @name = session.delete(:thanks)
  end

  def fetch_state_by_zip
    @json =
      if params[:zip] && params[:zip] =~ /\A\d\d\d\d\d\z/
        city, state = params[:zip].to_region.split(",")
        {city: city.strip, state: state.strip}
      else
        {}
      end
    respond_with(@json)
  end

  def map
    @donors = Donor.active
    @json = []
    @donors.each { |d| @json.push(:latitude => d.subscriber.latitude, :longitude => d.subscriber.longitude, :city => d.subscriber.city) }
    respond_with(@json)
  end

  private
  def donor_params
    params.require(:donor).permit(
      :add_fee, :public_name, {card_attributes: [:name, :email]}
    )
  end

  def donor_card_params
    params.require(:donor).permit(
      card_attributes: [:name, :email]
    )
  end
end
