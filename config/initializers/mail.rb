if ActionMailer::Base.delivery_method == :smtp
  mail_settings = YAML.load_file(File.join(Rails.root, 'config', 'mail.yml'))[Rails.env].symbolize_keys!

  ActionMailer::Base.perform_deliveries = true
  ActionMailer::Base.raise_delivery_errors = true
  ActionMailer::Base.smtp_settings = mail_settings
end

ActionMailer::Base.default_url_options = {
  host: CONFIG[:host],
  protocol: CONFIG[:protocol]
}
