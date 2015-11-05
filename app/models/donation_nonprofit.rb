class DonationNonprofit < ActiveRecord::Base
  belongs_to :donation
  belongs_to :nonprofit

  scope :executed, -> { where("donation_on <= ?", Time.zone.now.to_date) }
  scope :future,   -> { where("donation_on > ?", Time.zone.now.to_date) }

  private
  before_create :set_donation_on
  def set_donation_on
    # Hardcode the date that this part of the donation was for, as a safeguard
    self.donation_on = nonprofit.featured_on
  end
end
