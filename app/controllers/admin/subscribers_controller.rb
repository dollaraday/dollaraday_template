class Admin::SubscribersController < Admin::BaseController
  def index
    @q = Subscriber.includes(:donor).search(params[:q])
    @subscribers = @q.result(distinct: true)
  end

  def show
    @subscriber = Subscriber.find params[:id]
    @donor = @subscriber.donor
  end

  # Maybe someone entered the wrong email at first, changed it, and
  # requested us to resend the newsletter.
  def resend_newsletter
    @subscriber = Subscriber.find params[:id]
    @nonprofit = Nonprofit.find(params[:nonprofit_id])

    type = @subscriber.active_donor? ? "donor" : "subscriber"
    recipients = @subscriber.to_mailgun_recipient

    NewsletterMailer.batched_daily(type, @nonprofit.newsletter.id, recipients)
    email = @subscriber.emails.new(to: @subscriber.email,  newsletter: @nonprofit.newsletter, sent_at: Time.now, mailer: "NewsletterMailer", mailer_method: "daily_#{type}")
    email.save!(validate: false) # ugh, validation

    flash[:notice] = "Newsletter resent!"
    redirect_to admin_subscriber_url(@subscriber.id)
  end
end
