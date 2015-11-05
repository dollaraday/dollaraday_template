class SendGiftRecipientReminderEmailJob < DollarADayJob.new(:gift_id)
  @priority = 1
  @queue    = 'default'

  def perform
    GiftMailer.recipient_reminder(gift.id).deliver
    Email.create(to: subscriber.email, subscriber: subscriber, sent_at: Time.now, mailer: "GiftMailer", mailer_method: "recipient_reminder")
  end

  private

  def gift
    @gift ||= Gift.find(gift_id)
  end

  def subscriber
    gift.donor.subscriber
  end


end
