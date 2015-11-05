class SubscriberMailer < BaseMailer

  def email_changed(subscriber_id, new_email, old_email)
    @subscriber = Subscriber.find(subscriber_id)
    @new_email = new_email
    @old_email = old_email

    mail(to: @old_email, subject: 'Your email has been changed') do |format|
      format.html { render layout: 'base' }
    end
  end

end
