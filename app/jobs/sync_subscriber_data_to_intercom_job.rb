class SyncSubscriberDataToIntercomJob < DollarADayJob.new(:subscriber_id)
  @priority = 3
  @queue    = 'default'

  def perform
    intercom = Intercom::Client.new(app_id: INTERCOM[:key], api_key: INTERCOM[:api])

    user = intercom.users.create  user_id: subscriber.guid,
                                  name: subscriber.name,
                                  email: subscriber.email,
                                  signed_up_at: subscriber.created_at.to_i,
                                  last_seen_ip: subscriber.ip_address

    if subscriber.donor.present?
      user.custom_attributes['has_donated'] = true
      user.custom_attributes['active_donor'] = subscriber.donor.active?
      user.custom_attributes['total_donated'] = subscriber.donor.donations.executed.sum(:amount).to_i
    else
      user.custom_attributes['has_donated'] = false
    end

    user.custom_attributes['favorites'] = subscriber.favorites.count

    intercom.users.save user

  end

  protected

  def subscriber
    @subscriber ||= Subscriber.find(subscriber_id)
  end
end
