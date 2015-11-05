class ExecuteDonationJob < DollarADayJob.new(:donation_id)
  @priority = 1
  @queue    = 'default'

	def perform
		return if donation.executed? || !donation.locked?

    begin
      donation.execute!
      donation.update_attribute :locked_at, nil
    rescue Net::ReadTimeout => e
      # Don't unlock the donation, but consider this job run. We should get
      # the notification and act on it.
      ExceptionNotifier.notify_exception(e, data: {donation_id: donation_id})
    end
	end

  protected

  def donation
    @donation ||= Donation.find(donation_id)
  end

end
