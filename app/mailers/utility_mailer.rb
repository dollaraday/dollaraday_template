class UtilityMailer < BaseMailer
  default "to"        => "support@#{CONFIG[:host]}",
    "X-Mailgun-Track" => "no"

  def site_feedback(from_email, message)
    @from_email = from_email
    @message = message

    mail(
      subject: "[#{CONFIG[:name]}] Site Feedback",
      reply_to: @from_email) do |format|
      format.text
    end
  end
end
