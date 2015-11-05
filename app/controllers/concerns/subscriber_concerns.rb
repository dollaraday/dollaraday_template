module SubscriberConcerns
  extend ActiveSupport::Concern

  def load_subscriber
    @subscriber = Subscriber.where(guid: params[:subscriber_guid]).first or redirect_to root_url
  end

end
