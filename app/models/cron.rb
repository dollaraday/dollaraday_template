module Cron; end
class << Cron
  # intended to be called by cron every 15 minutes
  def tab
    t = Time.now.in_time_zone('Eastern Time (US & Canada)')
    logger.info "#{t} Running cron... "

    quarter_hourly
    if t.min < 15
      hourly
      if t.hour == 0
        daily_midnight
        weekly(t.wday)
        monthly if t.mday == 1
      elsif t.hour == 8
        daily_morning
      end
      daily if t.hour == 4
    end
  end

  # every 15 minutes
  def quarter_hourly
    logger.info "  quarter_hourly"
    run 'Delayed::Job', :report_queue
    run 'Donation', :execute_donations_scheduled_for_now
  end

  # every hour
  def hourly
    logger.info "  hourly"
    FinishCancelledDonorsJob.create({})
    run 'Donor', :check_for_duplicate_donations
  end

  # runs at midnight every night
  def daily_midnight
    logger.info "  daily_midnight"
    PersistStatsJob.create({})
    Gift.send_expiration_reminders(5)
    Gift.send_expiration_reminders(3)
    Gift.send_expiration_reminders(1)
  end

  # run at 8am every morning
  def daily_morning
    logger.info "  daily_morning"
    run('Newsletter', :send!)
  end

  # run at 4am every day
  def daily
    logger.info "  daily"
  end

  # run per weekday
  def weekly(d)
    logger.info "  weekly"
  end

  # run first day of every month
  def monthly
  end

  def logfile
    @logfile ||= Rails.root.join('log/cron.log').to_s
  end

  def lockfile
    @lockfile ||= Rails.root.join('CRONLOCK').to_s
  end

  def locked?
    File.exist?(lockfile)
  end

  def lock!
    FileUtils.touch(lockfile)
  end

  def unlock!
    File.delete(lockfile)
  end

  def logger
    @logger ||= Logger.new(logfile)
  end

  protected

  def run(klass, method, *args)
    if locked?
      if (mtime = File.mtime('CRONLOCK')) && File.mtime('CRONLOCK') < 30.minutes.ago
        puts "Sending AdminMailer#cron_issue because lock has existed since #{mtime}."
        AdminMailer.cron_issue(mtime).deliver
      end
    else
      lock!
      logger.info "Starting #{klass}.#{method} at #{Time.now}"
      begin
        ms = Benchmark.ms { perform_method(klass, method, *args) }
      rescue => e
        logger.info "****************************************"
        logger.info "ERROR IN CRON: #{e}"
        logger.info "****************************************"
        raise e
      end
      logger.info "Finished #{klass}.#{method} at #{Time.now} (#{ms}ms)"
      unlock!
    end
  end

  def perform_method(klass, method, *args)
    klass.constantize.send(method, *args)
  end
end
