S3 = YAML.load_file(File.join(Rails.root, 'config', 's3.yml'))[Rails.env].symbolize_keys!
