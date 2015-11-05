class Gift < ActiveRecord::Base
  has_one :donor
  belongs_to :giver_subscriber, class_name: "Subscriber", inverse_of: :given_gifts

  validates :donor, presence: true
  validates :message, presence: true
  validates :giver_subscriber, presence: true
  validates :months_remaining, inclusion: {
    in: [0, 1, 2, 3, nil] # expired, 30 days, 60 days, 90 days, infinite
  }

  scope :expiring_within_days, -> (days_until_expiry) {
    where("DATE_SUB(gifts.finish_on, INTERVAL ? DAY) = ?", days_until_expiry, Date.today)
  }
  scope :within_gifting_period, -> { where("months_remaining IS NULL OR finish_on > ?", Date.today) }
  scope :outside_gifting_period, -> { where("months_remaining IS NOT NULL AND finish_on <= ?", Date.today) }
  scope :active, -> { within_gifting_period.where(converted_to_recipient: false) }
  scope :converted, -> { outside_gifting_period.where(converted_to_recipient: true) }

  audited


  # Send out GiftMailer#recipient_reminder emails to gift recipients whose
  # gifts expire X days from now.
  def self.send_expiration_reminders(days_until_expiry = 5)
    Gift.where.expiring_within_days(days_until_expiry).each do |g|
      SendGiftRecipientReminderEmailJob.new(g.id).save
    end
  end


  def to_param
    donor.subscriber.try(:guid)
  end

  def active?
    !converted_to_recipient? && within_gifting_period?
  end

  def inactive?
    !within_gifting_period?
  end

  # TODO maybe 'finished?' is better term?
  def expired?
    !converted_to_recipient? && months_remaining == 0
  end

  def within_gifting_period?
    infinite? || Date.today < finish_on
  end

  def outside_gifting_period?
    !infinite && Date.today >= finish_on
  end

  def infinite?
    months_remaining.nil?
  end

  def decrement!
    update(months_remaining: months_remaining - 1) unless infinite?
  end

  # Assumes that the new donor card has been saved already
  def convert_to_recipient!
    update!(months_remaining: 0, converted_to_recipient: true)

    # NB donations will keep being rescheduled when they're expired (eg
    # Donation#schedule_next_donation), but they'll raise an ExpiredGift
    # error if they are. Let's detect those here and retry them.
    donor.donations.failed.first.try(:fix!)
  end

  private

  before_validation :preprocess, on: :create
  def preprocess
    self.start_on                    = Time.now.to_date
    self.finish_on                   = start_on + (months_remaining * 30) unless infinite?
    self.original_months_remaining   = months_remaining

    # These fields are mostly for record-keeping
    self.recipient_name              = donor.subscriber.name
    self.recipient_email             = donor.subscriber.email
    self.giver_name                  = donor.card.name
    self.giver_email                 = donor.card.email

    # We need +giver_subscriber+ so the giver has a Manage Account page for stuff
    self.giver_subscriber            = Subscriber.where(email: giver_email).first_or_initialize
    giver_subscriber.name            = giver_name            if giver_subscriber.name.blank? # populate the subscriber's name (means they existed already)
    giver_subscriber.email           = giver_email           if giver_subscriber.email.blank?
    giver_subscriber.ip_address      = donor.card.ip_address if giver_subscriber.ip_address.blank?
    giver_subscriber.unsubscribed_at = Time.now              if giver_subscriber.new_record? # NB if we're creating this Subscriber specifically for the gift giver, we don't actually want them to get newsletters. It's just for the Manage Account link.

    true
  end

  after_create :send_initial_emails
  def send_initial_emails
    SendGiftConfirmationEmailJob.new(self.id).save
    SendGiftRecipientInitialJob.new(self.id).save
  end

end
