class Nonprofit < ActiveRecord::Base
  ALLOWED_DESCRIPTION_TAGS = %w(b i a br p)

  has_many :favorites
  has_many :fans, through: :favorites,
                  class_name: 'Subscriber',
                  foreign_key: 'subscriber_id',
                  source: :subscriber

  has_many :donation_nonprofits
  has_many :donations, through: :donation_nonprofits
  has_many :payouts
  has_one  :newsletter

  scope :featured_from, ->(d) { where("featured_on >= ?", d).order("featured_on ASC") }
  scope :featured_reverse_from, ->(d) { where("featured_on <= ?", d).order("featured_on DESC") }
  scope :is_public, -> { where(is_public: true) }
  scope :for_next_possible_day, -> { featured_from(Date.today).order("featured_on ASC") }
  scope :requiring_payouts, -> {
    joins(:donations).
    uniq.
    merge(Donation.via_stripe).
    merge(Donation.executed)
  }


  audited

  has_attached_file :photo,
    {
      styles: {
        full: {geometry: "960x540>", format: :png},
        medium: {geometry: "480x270>", format: :png},
        thumb: {geometry: "100x100>" , format: :png}
      }
    }.merge(DollarADay::Application.config.paperclip_defaults)

  validates :name, presence: true
  validates :ein, format: { with: /\A\d\d?-\d{7}\z/ } 
  validates :slug, uniqueness: { message: "is already used by another Nonprofit", allow_nil: true }
  validates :featured_on, uniqueness: { message: "is already taken by another Nonprofit" }
  validates :blurb, presence: true
  validate :editability, on: :update
  validate :donatability
  validates_attachment :photo, content_type: { content_type: ["image/jpg", "image/jpeg", "image/png", "image/gif"] }

  def self.for_today
    Nonprofit.is_public.where(featured_on: Time.zone.now.to_date).first
  end

  def self.find_by_param(val)
    where(slug: val).first || find(val)
  end

  def self.description_sanitizer
    @description_sanitizer ||= begin
      HTML::WhiteListSanitizer.new.tap { |s|
        s.allowed_tags.reject! { true }
        ALLOWED_DESCRIPTION_TAGS.each { |tag|
          s.allowed_tags << tag
        }
        s
      }
    end
  end

  before_destroy :destroyable?
  def destroyable?
    new_record?
  end

  def displayable_donation_count
    donations.executed.map(&:donor_id).uniq.size
  end

  def to_param
    slug.presence || id.to_s
  end

  def related_nonprofits
    Nonprofit.where(ein: ein).where.not(id: id)
  end

  def twitter_or_name
    self.twitter.present? ? "@#{self.twitter}" : self.name
  end

  # Details about this nonprofit from external sources
  def details
    return @details if defined? @details

    @details = {}
    [
      Thread.new { @details[:propublica] = propublica_details },
      Thread.new { @details[:nfg] = nfg_details }
    ].map(&:join)

    @details
  end

  def propublica_details
    sanitized_ein = ein.to_s.gsub(/[^0-9]/, '')
    response = open("https://projects.propublica.org/nonprofits/api/v1/organizations/#{sanitized_ein}.json").read
    response = JSON.parse(response)
    response['organization']
  rescue OpenURI::HTTPError
    "NOT FOUND"
  end

  # NB this endpoint requires a Guidestar agreement with NFG
  def nfg_details
    @nfg_details ||= begin
      NetworkForGood::CreditCard.npo_detail_info(ein)
    rescue NetworkForGood::Base::InvalidEIN => e
      ExceptionNotifier.notify_exception(NetworkForGood::Base::UnexpectedResponse.new(resp), data: {nfg_response: e.response})
      nil
    end
  end

  # TODO could just migrate all of these to be uniform, and add a validation for the protocol
  def url
    u = read_attribute(:url)
    u !~ /\Ahttp/i ? "http://#{u}" : u
  end

  # How much, after fees, is due to this nonprofit from Stripe donations.
  def stripe_donation_total
    donations.via_stripe.executed.map(&:calculate_total_per_nonprofit).sum
  end

  def stripe_payout_total
    payouts.all.to_a.sum(&:amount)
  end

  private

  def editability
    if featured_on_changed? && donations.executed.exists?
      errors.add(:featured_on, "This nonprofit already has donations! You may not move it. If you want to refeature a Nonprofit, add a new one with the same EIN. ")
    end

    if ein_changed? and featured_on_was.present? and featured_on_was < 30.days.from_now
      errors.add(:ein, "May not edit EIN for nonprofits before #{30.days.from_now.to_date.to_s(:short)}! This nonprofit probably already has donations.")
    end
  end

  def donatability
    return if Rails.env.development? #or Rails.env.test?
    return unless ein_changed?

    # Call this endpoint to see if the Nonprofit is valid w/NFG.
    begin
      resp = NetworkForGood::CreditCard.get_fee(self)
      if resp[:error_details] && resp[:error_details][:error_info][:err_code] == "NpoNotEligible"
        errors.add(:ein, "NFG error: #{resp[:error_details][:error_info][:err_data]}")
      end
    rescue NetworkForGood::Base::UnexpectedResponse => e
      errors.add(:ein, "NFG error: #{e.response[:error_details][:error_info][:err_data]}")
    rescue Net::OpenTimeout => e
      errors.add(:ein, "NFG timeout while looking up nonprofit!")
    end
  end

  before_validation :attach_newsletter, on: :create
  def attach_newsletter
    unless newsletter.present?
      self.newsletter = Newsletter.new
    end
  end

  before_save :sanitize_fields
  def sanitize_fields
    self.description = Nonprofit.description_sanitizer.sanitize(description.to_s)
    self.ein = ein.to_s.strip
  end

  # Just a cross-check so we can to make sure the Nonprofits are matched to the proper EINs
  before_save :update_nfg_name
  def update_nfg_name
    if ein_changed?
      self.nfg_name = nfg_details[:npo_name]
    end
  end


end
