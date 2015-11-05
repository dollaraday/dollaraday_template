class AdminMailerPreview < ActionMailer::Preview
	def cron_issue
		AdminMailer.cron_issue(3.hours.ago)
	end

	def duplicate_donations
		AdminMailer.duplicate_donations(Donor.limit(3).pluck(:id))
	end
end
