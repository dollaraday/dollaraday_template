MAILGUN = YAML.load_file(File.join(Rails.root, 'config', 'mailgun.yml'))[Rails.env].symbolize_keys!
