class UtilityMailerPreview < ActionMailer::Preview
	def site_feedback
		UtilityMailer.site_feedback("feedbacker.user@****.com", "I would like to suggest a nonprofit named <a href='http://#{CONFIG[:host]}'>*******</a>.\nPlease email me for questions about the nonprofit.")
	end
end
