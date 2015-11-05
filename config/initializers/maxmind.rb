MAXMIND = YAML.load_file(File.join(Rails.root, 'config', 'maxmind.yml'))[Rails.env].symbolize_keys!
