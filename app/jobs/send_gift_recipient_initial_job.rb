# TODO test
class SendGiftRecipientInitialJob < DollarADayJob.new(:gift_id)
  @priority = 1
  @queue    = 'default'

  def perform
    # This is a one-off -- it's the gift welcome email + the first newsletter,
    # so it counts as the newsletter too (so we create the Email record still)
    GiftMailer.recipient_initial(gift.id).deliver
    Email.create(to: gift.donor.subscriber.email, newsletter: newsletter, subscriber: gift.donor.subscriber, sent_at: Time.now, mailer: "GiftMailer", mailer_method: "recipient_initial")
  rescue MailRecipientsFilter::NoRemainingRecipients => e
    # We can decide if we need to do more with these later
    Rails.logger.info "NoRemainingRecipients: SendGiftRecipientInitialJob#recipient_initial"
  end

  protected

  def gift
    @gift ||= Gift.find(gift_id)
  end

  def nonprofit
    @nonprofit ||= Nonprofit.is_public.where(featured_on: Time.zone.now.to_date).first!
  end

  def newsletter
    @newsletter ||= nonprofit.newsletter
  end
end
