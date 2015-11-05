class DonorMailer < BaseMailer

  # Declaring a @subscriber variable ensures a "Your Account" link

  def cancelled(donor_id)
    @donor = Donor.find(donor_id)
    last_donation = @donor.last_executed_donation

    @last_day = last_donation ? last_donation.executed_at.to_date + 30.days : Date.today

    mail(to: @donor.subscriber.email, subject: "Your #{CONFIG[:name]} donations have been cancelled") do |format|
      format.html { render layout: 'base' }
    end
  end

  def uncancelled(donor_id)
    @donor = Donor.find(donor_id)

    mail(to: @donor.subscriber.email, subject: "Welcome back to #{CONFIG[:name]}!") do |format|
      format.html { render layout: 'base' }
    end
  end

  def donation_failed(donor_id)
    @donor = Donor.find(donor_id)

    mail(to: @donor.subscriber.email, subject: "Oops! Your credit card didn’t process") do |format|
      format.html { render }
    end
  end

  def receipt(donation_id, stripe_charge)
    @donation = Donation.find(donation_id)
    @donor = @donation.donor
    @subscriber = @donor.subscriber
    @nonprofits = @donation.nonprofits
    @charge = stripe_charge

    mail(to: @subscriber.email, subject: "Your #{CONFIG[:name]} receipt [##{'%08d' % @donation.id}]")
  end

end
