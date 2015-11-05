class FinishCancelledDonorsJob < DollarADayJob.new
  @priority = 3
  @queue    = 'default'

  # Keeping this in a job so we get notified if anything goes wrong
  def perform
    Donor.finish_cancelled_donors
  end
end
