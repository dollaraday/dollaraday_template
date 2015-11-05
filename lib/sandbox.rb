# for testing in the console
class Sandbox
  DONOR_ATTRIBUTES = {
    add_fee:         false
  }

  STRIPE_DONOR_ATTRIBUTES = DONOR_ATTRIBUTES.merge(
    stripe_customer_id: "cus_xxxxxxxxxxxxxx" # a sandbox user
  )

  NFG_DONOR_ATTRIBUTES = DONOR_ATTRIBUTES.merge(
    nfg_donor_token: "xxxxxxxx-xxxx-xxxx-xxxx-xxxxxxxxxxxx"
  )

  CARD_ATTRIBUTES = {
    ip_address:      "0.0.0.0",
    email:           CONFIG[:developer_email],
    name:            "John Doe"
  }

  NFG_CARD_ATTRIBUTES = CARD_ATTRIBUTES.merge(
    nfg_cof_id:      "1244286",
    first_name:      "John",
    last_name:       "Doe",
    address1:        "123 Circle",
    address2:        "",
    city:            "Test City",
    state:           "NY",
    zip:             "10002",
    phone:           "5555555555",
    card_type:       "Amex",
    card_number:     "371449635398431",
    exp_month:       "12",
    exp_year:        "2016",
    csc:             "001",
  )

  STRIPE_CARD_ATTRIBUTES = {
    stripe_card_id:  "card_xxxxxxxxxxxxxxxxxxxxxxxx"
  }


  def self.get_test_donor(is_stripe = false, add_fee = false)
    d = Donor.new(is_stripe ? STRIPE_DONOR_ATTRIBUTES : NFG_DONOR_ATTRIBUTES)
    d.build_card(is_stripe ? STRIPE_CARD_ATTRIBUTES : NFG_CARD_ATTRIBUTES)
    d.add_fee = add_fee
    d.build_subscriber
    d.tap(&:valid?) #trigger validation so Subscriber is created
  end

  def self.get_test_donation(is_stripe = false, add_fee = false)
    donor = get_test_donor(is_stripe, add_fee)
    Donation.new(
      donor: donor,
      donor_card: donor.card,
      nonprofits: Nonprofit.limit(30),
    ).tap { |d|
      d.amount = d.calculate_amount
      d.added_fee = d.calculate_added_fee
    }
  end
end
