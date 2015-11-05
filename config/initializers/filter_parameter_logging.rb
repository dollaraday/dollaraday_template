# Be sure to restart your server when you modify this file.

# Configure sensitive parameters which will be filtered from the log file.
Rails.application.config.filter_parameters += [:password, :card_number, :csc]

if !Rails.env.develompent?
  Rails.application.config.filter_parameters += [:exp_month, :exp_year, :last_4]
end
