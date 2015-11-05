INTERCOM = YAML.load_file(File.join(Rails.root, 'config', 'intercom.yml'))[Rails.env].symbolize_keys!
