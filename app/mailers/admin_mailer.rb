class AdminMailer < BaseMailer
  default "to"        => Rails.env.production? ? [CONFIG[:developer_email]],
    "X-Mailgun-Track" => "no"

  def delayed_jobs
    @errored_jobs = Delayed::Job.stuck
    @backlog      = Delayed::Job.backlogged

    subject_pcs = []
    subject_pcs << "#{@errored_jobs.count} Errored" if @errored_jobs.count > 0
    subject_pcs << "#{@backlog.count} Backlogged" if @backlog.count > 0

    mail subject: "[#{Rails.env.capitalize} - #{CONFIG[:name]}] Job Queue: #{subject_pcs.join(' / ')}" do |format|
      format.html
    end
  end

  def cron_issue(lock_mtime)
    @minutes = ((Time.now - lock_mtime) / 1.minute).to_i

    mail subject: "[#{Rails.env.capitalize} - #{CONFIG[:name]}] Cron Issue" do |format|
      format.html
    end
  end

  def duplicate_donations(donor_ids)
    @donors = Donor.find(donor_ids)

    mail subject: "[#{Rails.env.capitalize} - #{CONFIG[:name]}] Alert: duplicate donations found!" do |format|
      format.html
    end
  end
end
