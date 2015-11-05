class SubscriberMailerPreview < ActionMailer::Preview
	def email_changed
		SubscriberMailer.email_changed(subscriber.id, "a.new.email@****.com", subscriber.email)
	end

  private
  def subscriber
    @subscriber ||= Subscriber.first
  end

end
