class ImageMailer < BaseMailer
  layout 'image'

  # NB: this is for one-off image emails. There's a "image.text.erb" version
  # with existing text -- remember to change that when this is reused!!!!!!!!!
  #
  # For now, just run these in the console manually, something like this:
  # Subscriber.active.each do |s|
  #   puts s.email
  #   ImageMailer.image(s.email, "Hey! We think you're great", "thanks_email", "thanks_email")
  #   Email.create!(subscriber: s, mailer: "ImageMailer", mailer_method: "image", sent_at: Time.now)
  # end
  def image(to, subject, campaign, tag)
    subject = subject # "Thanks" email
    headers['X-Mailgun-Campaign-Id'] = campaign
    headers['X-Mailgun-Tag']         = tag

    mail(to: to, subject: subject) do |format|
      format.html
      format.text
    end
  end
end
