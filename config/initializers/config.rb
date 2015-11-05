CONFIG = YAML.load_file(File.join(Rails.root, 'config', 'config.yml'))[Rails.env].symbolize_keys!


# Load order issue -- gotta load these here instead of development.rb
if Rails.env.development?
  Rails.application.config.action_controller.asset_host = CONFIG[:host]
  Rails.application.config.action_mailer.asset_host = "http://#{CONFIG[:host]}"
end
