class ImageMailerPreview < ActionMailer::Preview
  def image
		to = "donor@****.com"
    subject = 'Thank You!'
    ImageMailer.image(to, subject, 'thanks_email', 'thanks_email')
  end
end
