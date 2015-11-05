# TODO test
class SendFirstNewsletterJob < DollarADayJob.new(:subscriber_id)
  @priority = 1
  @queue    = 'default'

  def perform
    return true if Email.where(subscriber_id: subscriber.id, newsletter_id: newsletter.id).exists?

    # The first newsletter for a Giftee is sent separately in SendGiftRecipientInitialJob.
    return true if subscriber.try(:donor).try(:gift).present?

    type = subscriber.active_donor? ? "donor" : "subscriber"

    NewsletterMailer.batched_daily(type, newsletter.id, subscriber.to_mailgun_recipient, is_first: true)

    Email.create(to: subscriber.email, newsletter: newsletter, subscriber: subscriber, sent_at: Time.now, mailer: "NewsletterMailer", mailer_method: "daily_#{type}")
  rescue MailRecipientsFilter::NoRemainingRecipients => e
    # We can decide if we need to do more with these later
    Rails.logger.info "NoRemainingRecipients: SendFirstNewsletterJobMailer#welcome"
  end

  protected

  def subscriber
    @subscriber ||= Subscriber.find(subscriber_id)
  end

  def nonprofit
    @nonprofit ||= Nonprofit.is_public.where(featured_on: Time.zone.now.to_date).first!
  end

  def newsletter
    @newsletter ||= nonprofit.newsletter
  end
end
