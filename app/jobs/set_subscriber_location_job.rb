class SetSubscriberLocationJob < DollarADayJob.new(:subscriber_id)
  @priority = 10
  @queue    = 'default'

  def perform
    subscriber.set_location
  end

  protected

  def subscriber
    @subscriber ||= Subscriber.find(subscriber_id)
  end
end
