# Be sure to restart your server when you modify this file.

# Version of your assets, change this if you want to expire all your assets.
Rails.application.config.assets.version = '4.0'

# Precompile additional assets.
# application.js, application.css, and all non-JS/CSS in app/assets folder are already added.
# Rails.application.config.assets.precompile += %w( search.js )

Rails.application.config.assets.precompile += %w(admin.js share.js donor_test.js)

# Mailer stylesheet
Rails.application.config.assets.precompile += %w(mailer.css)

# this was recommended by devise setup?
Rails.application.config.assets.initialize_on_precompile = false