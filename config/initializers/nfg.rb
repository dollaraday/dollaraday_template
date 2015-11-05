NFG = YAML.load_file(File.join(Rails.root, 'config', 'nfg.yml'))[Rails.env].symbolize_keys!
