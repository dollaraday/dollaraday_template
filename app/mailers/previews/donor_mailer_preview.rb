class DonorMailerPreview < ActionMailer::Preview
	def cancelled
		DonorMailer.cancelled(donor.id)
	end

	def uncancelled
    donor = Donor.joins(:donations).merge(Donation.pending).order("count(donations.id) DESC").first
		DonorMailer.uncancelled(donor.id)
	end

  def donation_failed
    DonorMailer.donation_failed(donor.id)
  end

  def receipt
    charge = OpenStruct.new(source: OpenStruct.new(last4: '1234', brand: 'Visa'))
    DonorMailer.receipt(Donation.where('amount > 0').order('RAND()').first.id, charge)
  end

  private
  def donor
    @donor ||= Donor.select("donors.*, count(donations.id) as donation_count").joins(:donations).order("donation_count desc").first
  end
end
