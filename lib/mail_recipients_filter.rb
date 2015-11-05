class MailRecipientsFilter
  class NoRemainingRecipients < StandardError
    def initialize(filtered_addrs)
      super "All original recipients were filtered: #{filtered_addrs.join(', ')}"
    end
  end

  class << self
    def delivering_email(message)
      original_destinations = message.destinations
      filter_recipients(message)
      raise NoRemainingRecipients.new(original_destinations) if message.destinations.empty?
    end

    def filter_recipients_hash(recipients={})
      allowed, dropped = recipients.partition do |address, recipient|
        allowed_address?(address)
      end

      Hash[dropped].each do |address, recipient|
        Rails.logger.info "Removed email address from recipients json: #{address}"
      end

      Hash[allowed]
    end

    private

    def allowed_emails
      ALLOWED_EMAILS
    end

    def filter_recipients(message)
      %w{to cc bcc}.each do |header|
        next if message.send(header).blank?

        allowed, dropped = message.send("#{header}_addrs").partition do |address|
          allowed_address?(address)
        end

        dropped.each do |address|
          Rails.logger.info "Removed email address from '#{header}' header: #{address}"
        end

        message.send("#{header}=", allowed)
      end
    end

    def allowed_address?(address)
      allowed_emails.any? do |email|
        address =~ /#{Regexp.escape(email).gsub('\\*','.*')}/i
      end
    end

  end
end
