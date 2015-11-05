class SendDailyDonorNewsletterJob < DollarADayJob.new(:nonprofit_id)
  @queue        = 'default'
  @priority     = 1
  @max_attempts = 1

  def perform
    raise "Already sent!" if nonprofit.newsletter.donors_sent_at.present?

    nonprofit.newsletter.send_donor!
  rescue MailRecipientsFilter::NoRemainingRecipients => e
    # We can decide if we need to do more with these later
    Rails.logger.info "NoRemainingRecipients: SendDailyDonorNewsletterJob"
  end

  protected

  def nonprofit
    @nonprofit ||= Nonprofit.is_public.find(nonprofit_id)
  end
end
