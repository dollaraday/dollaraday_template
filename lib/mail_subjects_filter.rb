class MailSubjectsFilter
  def self.delivering_email(message)
    unless Rails.env.production?
      message.subject = "[#{Rails.env}] #{message.subject}"
    end
  end
end
