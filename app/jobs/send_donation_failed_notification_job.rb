class SendDonationFailedNotificationJob < DollarADayJob.new(:donor_id)
  @priority = 3
  @queue    = 'default'

  def perform
    DonorMailer.donation_failed(donor.id).deliver
    Email.create(to: donor.subscriber.email, subscriber: donor.subscriber, sent_at: Time.now, mailer: "DonorMailer", mailer_method: "donation_failed")
  end

  protected

  def donor
    Donor.find(donor_id)
  end
end
