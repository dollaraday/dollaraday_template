class Newsletter < ActiveRecord::Base
  validates :nonprofit_id, presence: true

  belongs_to :nonprofit
  belongs_to :sender, class_name: "User"
  has_many   :emails

  audited

  def self.random
    rand_id = rand(Newsletter.count)
    rand_record = Newsletter.where(['id >= ?', rand_id]).first
  end

  # Send today's newsletter
  def self.send!
    n = Nonprofit.is_public.where(featured_on: Time.zone.now.to_date).first

    SendDailyDonorNewsletterJob.new(n.id).save
    SendDailySubscriberNewsletterJob.new(n.id).save
  end

  def send_subscriber!
    # Mailgun allows 1000 at a time, but we'll be safe with 100
    todays_subscribers.in_groups_of(100, false).each do |subscriber_batch|
      recipients = subscriber_batch.each_with_object({}) { |subscriber, recipients|
        recipients.merge!(subscriber.to_mailgun_recipient)
      }

      unless recipients.blank?
        NewsletterMailer.batched_daily("subscriber", id, recipients)

        # Keep a record of each subscriber email we sent for this Newsletter
        subscriber_batch.each { |s|
          emails.create(subscriber: s, sent_at: Time.now, mailer: "NewsletterMailer", mailer_method: "daily_subscriber")
        }
      end
    end

    update_attributes!(
      subscribers_sent_at: Time.now,
      subscriber_generated: subscriber_generate # a record of what the newsletter looked like when it was sent
    )
  end

  def send_donor!
    # Mailgun allows 1000 at a time, but we'll be safe with 100
    todays_donors.in_groups_of(100, false).each do |donor_batch|
      recipients = donor_batch.each_with_object({}) { |donor, recipients|
        recipients.merge!(donor.subscriber.to_mailgun_recipient)
      }

      unless recipients.blank?
        NewsletterMailer.batched_daily("donor", id, recipients)

        # Keep a record of each donor email we sent for this Newsletter
        donor_batch.each { |d|
          emails.create(subscriber: d.subscriber, sent_at: Time.now, mailer: "NewsletterMailer", mailer_method: "daily_donor")
        }
      end
    end

    update_attributes!(
      donors_sent_at: Time.now,
      donor_generated: donor_generate # a record of what the newsletter looked like when it was sent
    )
  end

  # Reset the newsletter so it can be sent again - mostly for testing so far
  def reset!
    update_attributes!(
      donor_generated:  nil,
      subscriber_generated: nil,
      donors_sent_at:   nil,
      subscribers_sent_at:  nil
    )
  end

  # Were any of the newsletters sent out already?
  def sent?
    subscribers_sent_at? or donors_sent_at?
  end

  # Generate the newsletter for donors
  def donor_generate
    donor_generated.presence || NewsletterMailer.daily_donor(self.id).html_part.decoded.to_s
  end

  # Generate the newsletter for non-donor subscribers
  def subscriber_generate
    subscriber_generated.presence || NewsletterMailer.daily_subscriber(self.id).html_part.decoded.to_s
  end

  def todays_donors
    @todays_donors ||= Donor.for_daily_newsletter.reject do |d|
      # Ignore donors who already received daily newsletter
      # (ie users who signed up before ~8am or whatever, or maybe if this DJ is
      # retrying after a failure halfway thru
      d.subscriber.emails.where(newsletter_id: id).exists?
    end
  end

  def todays_subscribers
    @subscribers ||= Subscriber.for_daily_newsletter.reject do |s|
      # Ignore subs who already received daily newsletter
      # (ie users who signed up before ~8am or whatever, or maybe if this DJ is
      # retrying after a failure halfway thru
      s.emails.where(newsletter_id: id).exists?
    end
  end
end
