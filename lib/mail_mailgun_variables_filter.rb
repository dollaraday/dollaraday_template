# Replaces URL-encoded %recipient.whatever% tags with non-encoded
class MailMailgunVariablesFilter

  class << self

    def replace(message)
      %i(html_part text_part).each do |part|
        next if message.send(part).blank?
        message.send(part).body = message.send(part).body.decoded.gsub(/%(?:25){1,2}(recipient.\w+)%(?:25){1,2}/, '%\1%')
      end
    end

    alias_method :delivering_email, :replace
    alias_method :previewing_email, :replace

  end
  
end