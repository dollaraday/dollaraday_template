class SendCancelledJob < DollarADayJob.new(:donor_id)
  @priority = 1
  @queue    = 'default'

  def perform
    DonorMailer.cancelled(donor).deliver
    Email.create(to: donor.subscriber.email, subscriber: donor.subscriber, sent_at: Time.now, mailer: "DonorMailer", mailer_method: "cancelled")
  rescue MailRecipientsFilter::NoRemainingRecipients => e
    # We can decide if we need to do more with these later
    Rails.logger.info "NoRemainingRecipients: DonorMailer#cancelled"
  end

  protected

  def donor
    @donor ||= Donor.find(donor_id)
  end
end
