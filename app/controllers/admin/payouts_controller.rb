# Display donations to be disbursed to nonprofits (via Stripe donations).
class Admin::PayoutsController < Admin::BaseController
  respond_to :html, :json

  def index
    @nonprofits = Nonprofit.requiring_payouts
  end

  def create
    amount = params[:amount].to_d
    nonprofit = Nonprofit.find(params[:nonprofit_id])

    @payout = nonprofit.payouts.new(
      amount: amount,
      user: current_user,
      payout_at: Time.now
    )
    @payout.save!

    redirect_to admin_payouts_url, notice: "You've confirmed payment of $%.2f to #{nonprofit.name}" % @payout.amount
  rescue ActiveRecord::RecordInvalid => e
    @nonprofits = Nonprofit.requiring_payouts
    redirect_to admin_payouts_url, alert: @payout.errors.full_messages.join(" ")
  end
end
