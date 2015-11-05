class SendEmailChangedNotificationJob < DollarADayJob.new(:subscriber_id, :new_email, :old_email)
  @priority = 1
  @queue    = 'default'

  def perform
    SubscriberMailer.email_changed(subscriber.id, new_email, old_email).deliver
    Email.create(to: subscriber.email, subscriber: subscriber, sent_at: Time.now, mailer: "SubscriberMailer", mailer_method: "email_changed")
  end

  private

  def subscriber
    @subscriber ||= Subscriber.find(subscriber_id)
  end

end
