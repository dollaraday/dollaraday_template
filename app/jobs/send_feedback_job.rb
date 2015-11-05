class SendFeedbackJob < DollarADayJob.new(:from_email, :message)
  @priority = 5
  @queue    = 'default'

  def perform
    UtilityMailer.site_feedback(from_email, message).deliver
  end
end
