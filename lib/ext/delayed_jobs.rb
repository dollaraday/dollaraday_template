class Delayed::Job
  scope :stuck, ->{ errored.where('attempts > 2 OR failed_at IS NOT NULL') }
  scope :errored, ->{ where.not(last_error: nil) }
  scope :backlogged, lambda{ where("run_at < ?", 15.minutes.ago).where(last_error: nil, locked_at: nil) }

  scope :current, lambda{ where('run_at <= ? OR last_error IS NOT NULL', Time.zone.now) }
  scope :future, lambda{ where('run_at > ? AND last_error IS NULL', Time.zone.now) }

  def self.report_queue
    AdminMailer.delayed_jobs.deliver if stuck.count > 0 or backlogged.count > 0
  end
end
