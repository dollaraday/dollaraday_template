class NewsletterMailerPreview < ActionMailer::Preview
  def first_daily_donor
    to = "donor@****.com"
    NewsletterMailer.daily_donor(Newsletter.random.id, to, true)
  end

  def first_daily_subscriber
    to = "subscriber@****.com"
    NewsletterMailer.daily_subscriber(Newsletter.random.id, to, true)
  end

  def daily_donor
    to = "donor_donor@****.com"
    NewsletterMailer.daily_donor(Newsletter.random.id, to)
  end

  def daily_subscriber
    to = "subscriber@****.com"
    NewsletterMailer.daily_subscriber(Newsletter.random.id, to)
  end
end
