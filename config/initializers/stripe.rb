STRIPE = YAML.load_file(File.join(Rails.root, 'config', 'stripe.yml'))[Rails.env].symbolize_keys!

Stripe.api_key = STRIPE[:secret_key]

module Stripe
	def self.logger
		@logger ||= Logger.new("log/stripe.log")
	end
end