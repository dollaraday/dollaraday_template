class SendGiftConfirmationEmailJob < DollarADayJob.new(:gift_id)
  @priority = 1
  @queue    = 'default'

  def perform
    GiftMailer.giver_confirmation(gift.id).deliver
    Email.create(to: gift.giver_subscriber.email, subscriber: gift.giver_subscriber, sent_at: Time.now, mailer: "GiftMailer", mailer_method: "giver_confirmation")
  end

  private

  def gift
    @gift ||= Gift.find(gift_id)
  end

end
