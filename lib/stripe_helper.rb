class StripeHelper

  def self.charge donation
    Stripe::Charge.create({
      amount: (donation.total * 100).floor,
      currency: "usd",
      customer: donation.donor.stripe_customer_id,
      source: donation.donor_card.stripe_card_id,
      description: "#{CONFIG[:name]} donation to:\n#{donation.nonprofits.sort_by(&:featured_on).map(&:name).join(",\n")}",
      statement_descriptor: "#{CONFIG[:name]} donation", # max 22 chars
      # NB if you want to use Stripe's built-in receipts instead of the app's
      # receipt_email: donation.donor_card.email,
      metadata: {
        donation_id: donation.id,
        donor_id: donation.donor.id,
        donor_card_id: donation.donor_card.id
      }
    })
  end

end
