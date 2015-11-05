class GiftsController < ApplicationController
  before_filter :require_donor, only: [:convert, :update]
  before_filter :initialize_gift, only: [:new, :create]

  respond_to :html


  def new
    @hide_donate_button = true
    @hide_footer = true
    @hide_header = true

    respond_with(@donor)
  end

  def create
    @hide_donate_button = true
    @hide_footer = true
    @hide_header = true

    # Awkward to use @donor instead of @gift here, but we're dealing with donor_params insetad of gift_params
    @donor.attributes            = donor_params
    @donor.card.ip_address       = request.ip

    @donor.card.stripe_token = params[:stripeToken] if params["stripeToken"].present?

    Gift.transaction do
      @donor.save!

      # Have the first donation execute immediately (instead of the 15-minute
      # cron interval) so it seems more immediate.
      @donor.donations.pending.first.lock_and_execute!
      session[:thanks] = @donor.subscriber.first_name
      redirect_to thanks_gifts_url
    end
  rescue ActiveRecord::RecordInvalid, ActiveRecord::RecordNotSaved => e
    render 'gifts/new'
  end

  # Like 'edit' -- for recipient to switch donations to their card
  def convert
    @new_card = current_donor.cards.new(email: current_donor.subscriber.email)
  end

  # TODO cleanup
  def update
    redirect_to root_url unless current_donor.gift.present?

    @new_card            = DonorCard.new(donor_card_params[:card_attributes])
    @new_card.is_active  = false
    @new_card.ip_address = request.ip
    @new_card.donor      = current_donor # inverse_of?
    @new_card.stripe_token = params[:stripeToken]
    @new_card.stripe_email = params[:stripeEmail]
    @new_card.save!

    current_donor.reload
    current_donor.try(:card).try(:deactivate!)
    @new_card.activate!
    current_donor.gift.convert_to_recipient!

    flash[:notice] = "Thanks! The donations for this gift will start using your credit card."
    redirect_to root_url
  rescue ActiveRecord::RecordInvalid => e
    render :convert
  end

  def thanks
    @hide_header = true
    @hide_footer = true

    @name = session['thanks']
  end

  # TODO rack-attack this?
  # Checks if donor exists -- regardless of active/inactive/cancelled state
  def exists
    if @donor = Subscriber.where(email: params[:email].to_s).first.try(:donor)
      msg = "Woops, that person is already a donor!"

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

  private

  def donor_params
    params.require(:donor).permit(
      :add_fee,
      {
        gift_attributes: [:months_remaining, :message],
        subscriber_attributes: [:name, :email],          # Gift#recipient_name, Gift#recipient_email
        card_attributes: [:name, :email]                 # Gift#giver_name, Gift#giver_email
      }
    )
  end

  def donor_card_params
    params.require(:donor).permit(
      card_attributes: [:name, :email]
    )
  end
end
