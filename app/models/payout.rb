class Payout < ActiveRecord::Base
	belongs_to :nonprofit
	belongs_to :user

	validates :nonprofit, presence: true
	validates :user, presence: true


	validate :cannot_exceed_donations
	def cannot_exceed_donations
		due = (nonprofit.stripe_donation_total - nonprofit.stripe_payout_total)

		if amount > due
			errors.add(:amount, " ($#{"%.2f" % amount}) cannot exceed the donations due ($#{"%.2f" % due}).")
		end
	end

end