class Donation < ActiveRecord::Base
  NUMBER_OF_NONPROFITS = 30

  NFG_FEE_PERCENT    = 0.04
  STRIPE_FEE_FIXED   = 0.30
  STRIPE_FEE_PERCENT = 0.029

  class DonationAlreadyCancelled < StandardError; end

  # When a donation has nonprofits (based on the date) that were already donated
  # in the donor's previous donations.
  class OverlappingDonationNonprofits < StandardError; end

  # When there aren't enough nonprofits (30) to run the donation.
  class NotEnoughNonprofitsForDonation < StandardError; end

  # When 2+ nonprofits for a donation were featured on the same day.
  class NonprofitsFeaturedOnDuplicateDaysInDonation < StandardError; end

  # When a COF has expired, cancelled, or been deactivated and is not available.
  class NoAvailableCOF < StandardError; end

  # Just in case a Nonprofit opts-out and causes the donation to fail.
  class InvalidNonprofit < StandardError; end

  # When a gift has expired, but for some reason there's a donation pending
  # (shouldn't happen, we'll check-and-raise just as a safeguard).
  class ExpiredGift < StandardError; end

  audited

  def self.denomination
    1.00
  end

  def self.execute_donations_scheduled_for_now
    pending.where("scheduled_at <= ? ", Time.now).each do |donation|
      donation.lock_and_execute!
    end
  end

  belongs_to :donor, touch: true
  belongs_to :donor_card
  has_many :donation_nonprofits
  has_many :nonprofits, through: :donation_nonprofits

  has_many :executed_nonprofit_donations, -> { executed },  class_name: "DonationNonprofit"
  has_many :future_nonprofit_donations,   -> { future },    class_name: "DonationNonprofit"

  has_many :donated_nonprofits, through: :executed_nonprofit_donations, source: :nonprofit
  has_many :future_nonprofits,  through: :future_nonprofit_donations,   source: :nonprofit

  validates :donor, presence: true
  validates :donor_card, presence: true
  validates :scheduled_at, presence: true
  validates :guid, uniqueness: true

  validates_presence_of :nfg_charge_id, if: lambda { self.executed? and !self.stripe? }
  validates_presence_of :stripe_charge_id, if: lambda { self.executed? and self.stripe? }

  scope :pending,   -> { where(executed_at: nil, locked_at: nil, failed_at: nil, cancelled_at: nil, disputed_at: nil, refunded_at: nil) }
  scope :executed,  -> { where.not(executed_at: nil) }
  scope :cancelled, -> { where.not(cancelled_at: nil) }
  scope :locked,    -> { where.not(locked_at: nil) }
  scope :failed,    -> { where.not(failed_at: nil) }
  scope :disputed,  -> { where.not(disputed_at: nil) }
  scope :refunded,  -> { where.not(refunded_at: nil) }

  scope :via_nfg,    -> { where.not(nfg_charge_id: nil) }
  scope :via_stripe, -> { where.not(stripe_charge_id: nil)}


  def pending?
    !executed? && !locked? && !cancelled?
  end

  def locked?
    locked_at.present?
  end

  def failed?
    failed_at.present?
  end

  def disputed?
    disputed_at.present?
  end

  def refunded?
    refunded_at.present?
  end

  def cancelled?
    cancelled_at.present?
  end

  def executed?
    executed_at.present?
  end

  def stripe?
    executed? ? stripe_charge_id.present? : donor.card.stripe?
  end

  # We want the lock so that we don't create extraneous DJs from cron.rb
  # on a regular basis.
  def lock_and_execute!
    update_attribute :locked_at, Time.now
    ExecuteDonationJob.new(id).save(run_at: scheduled_at)
  end

  def execute!
    # Make sure we're using the current active card.
    attach_donor_card

    raise DonationAlreadyCancelled.new if cancelled?
    raise NoAvailableCOF.new unless stripe? || donor_card.cof_exists?
    raise ExpiredGift.new if donor.gift && donor.gift.expired?

    add_scheduled_nonprofits

    self.amount = calculate_amount                # $30
    self.added_fee = calculate_added_fee          # if opted-in, extra amount necessary to give all $30 to nonprofits
    self.total = calculate_total                  # $30 + extra
    self.total_minus_fee = total - calculate_fee  # ($30 + extra) - fee

    charge_or_success = stripe? ? execute_via_stripe! : execute_via_nfg!

    if charge_or_success
      self.executed_at = Time.now
      save!
      DonorMailer.receipt(self, charge_or_success).deliver if stripe?
      Email.create(to: donor.subscriber.email, subscriber: donor.subscriber, sent_at: Time.now, mailer: "DonorMailer", mailer_method: "receipt")
    end
  rescue NoAvailableCOF => e
    ExceptionNotifier.notify_exception(e)
    fail!(e.message, notify_donor: true)
  rescue ExpiredGift => e
    ExceptionNotifier.notify_exception(e)
    fail!(e.message, notify_donor: false)
  end

  def execute_via_stripe!
    charge = StripeHelper.charge(self)
    self.stripe_charge_id = charge.id

    charge
  rescue Stripe::CardError => e
    # card decline/expired/cancelled
    ExceptionNotifier.notify_exception(e)

    fail!(e.message, notify_donor: true)
  rescue Stripe::InvalidRequestError,
         Stripe::AuthenticationError,
         Stripe::APIConnectionError,
         Stripe::StripeError => e

    ExceptionNotifier.notify_exception(e)

    fail!(e.message, notify_donor: false)
  end

  def execute_via_nfg!
    resp = NetworkForGood::CreditCard.make_cof_donation self

    if resp.is_a?(Array)
      # For example: [{:err_code=>"NpoNotEligible", :err_data=>"The NPO with EIN = \"98-0115409\" [Pro Mujer Inc.] has chosen not to receive online donations through Network for Good"}]
      # TODO could we pull these into the NFG classes?
      raise NetworkForGood::Base::ChargeFailed.new(resp)
    else
      self.nfg_charge_id = resp[:charge_id]
      true
    end
  rescue NetworkForGood::Base::Error => e
    # Notify us (to learn more about these errors), and mark donor as failed
    ExceptionNotifier.notify_exception(NetworkForGood::Base::UnexpectedResponse.new(resp), data: {nfg_response: e.message})

    # We don't want to notify users when an error is caused by "NpoNotEligible".
    notify_donor = e.message =~ /NpoNotEligible/ ? false : true
    fail!(e.message, notify_donor: notify_donor)
  end

  # Call this if you've just refunded a transaction on Stripe's UI.
  # TODO add tests
  # TODO UI or some webhook from Stripe to trigger this instead of manually?
  # NB refunds include refunded fees, so everything should zero out
  def refunded!(msg)
    self.refunded_at = Time.now
    self.executed_at = nil
    self.audit_comment = msg

    self.save!
  end

  # Call this if you've just marked a transaction dispute as resolved on Stripe's UI.
  # TODO add tests
  # TODO UI or some webhook from Stripe to trigger this instead of manually?
  # TODO disputes add an addtl $15 charge -- need to accoutn for that somehow
  def disputed!(msg)
    self.disputed_at = Time.now
    self.executed_at = nil
    self.audit_comment = msg

    self.save!
  end

  def fail!(msg, notify_donor: true)
    self.failed_at = self.donor.failed_at = Time.now
    self.last_failure = msg
    self.failed_at

    self.save!
    self.donor.save!

    if notify_donor
      SendDonationFailedNotificationJob.new(donor.id).save
    end

    false
  end

  def fix!
    self.failed_at = self.donor.failed_at = nil

    # If their donation failed within the last 30 days, run the donation
    # for it's original date (bc they might've signed up for 1 of those
    # nonprofits intentionally).
    # If their donation failed >30 days ago, we don't want to play "catch-up"
    # and charge them potentially 2+ times in a row, so just restart them right now.
    if scheduled_at < 30.days.ago
      donation_nonprofits.destroy_all # clear these out -- they'd be set to the original 30 nonprofits
      self.scheduled_at = Time.now
    end

    self.save!
    self.donor.save!
  end

  def calculate_amount
    nonprofits.size * Donation.denomination
  end

  def calculate_added_fee
    if donor.add_fee?
      if stripe?
        # https://support.stripe.com/questions/can-i-charge-my-stripe-fees-to-my-customers
        # 2.9% + 30¢
        (((calculate_amount + STRIPE_FEE_FIXED) / (1 - STRIPE_FEE_PERCENT)) - calculate_amount)
      else
        # don't need complicated calculation like stripe as NFG assumes fee is included
        # 4.0%
        calculate_amount * NFG_FEE_PERCENT
      end
    else
      0.0
    end
  end

  # The recorded amount + fee
  def calculate_total
    (amount || 0).to_d + (added_fee || 0).to_d
  end

  # The actual fee taken, whether donor has added_fee or not
  def calculate_fee
    if stripe?
      # Stripe::Charge.retrieve(id: stripe_charge_id, expand: ['balance_transaction'])
      ((calculate_total * STRIPE_FEE_PERCENT) + STRIPE_FEE_FIXED).round(2)
    else
      # NetworkForGood::CreditCard.get_fee(Nonprofit.last)[:total_add_fee].to_d
      (amount * NFG_FEE_PERCENT).round(2)
    end
  end

  # how much each nonprofit gets for this
  def calculate_total_per_nonprofit
    (total_minus_fee / donation_nonprofits.count.to_d).floor(2)
  end

  def scheduled_nonprofits
    dates = (0..NUMBER_OF_NONPROFITS-1).map { |i| scheduled_at.to_date + i }

    Nonprofit.is_public.where(featured_on: dates).limit(NUMBER_OF_NONPROFITS)
  end

  private
  before_validation :set_guid, on: :create
  def set_guid
    self.guid = guid.presence || SecureRandom.hex(16)
  end

  before_validation :attach_donor_card
  def attach_donor_card
    # TODO should this always be true?
    self.donor_card = donor.card
  end

  after_update :schedule_next_donation
  def schedule_next_donation
    # TODO good justification for a state machine
    if executed? and executed_at_was.nil? and donor.cancelled_at.blank?
      # NB schedule at 12am, so the newsletter at 8am has a more accurate donor count
      donor.donations.create!(scheduled_at: 30.days.since(scheduled_at).beginning_of_day)
    end
  end

  # TODO test
  after_update :decrement_gift
  def decrement_gift
    return unless donor.gift.try(:active?) && executed_at_was.nil? && executed_at.present?

    donor.gift.decrement!
  end

  def add_scheduled_nonprofits
    return if nonprofits.present?

    n = scheduled_nonprofits

    # Run some checks to make sure this donation is sane.

    # TODO better way to write this? maybe a JOIN
    previous_nonprofit_ids = donor.donations.executed.map { |d| d.donation_nonprofits.pluck(:nonprofit_id) }.flatten
    common_nonprofits = n.map(&:id) & previous_nonprofit_ids
    if common_nonprofits.present?
      raise Donation::OverlappingDonationNonprofits.new(common_nonprofits)
    end

    # TODO write a test
    if n.size != n.map(&:featured_on).uniq.size
      raise Donation::NonprofitsFeaturedOnDuplicateDaysInDonation.new("Donation #{id}. Nonprofit ids: #{n.map(&:id)}")
    end

    if n.size != NUMBER_OF_NONPROFITS
      raise Donation::NotEnoughNonprofitsForDonation.new("Actual: #{n.size}, Expected: #{NUMBER_OF_NONPROFITS}")
    end


    self.nonprofits << n
  end
end
