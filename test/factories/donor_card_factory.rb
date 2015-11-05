FactoryGirl.define do
  factory :nfg_donor_card, class: DonorCard do
    nfg_cof_id { rand(10000000).to_s }
    is_active true
    email { FactoryGirl.generate(:email) }
    name { FactoryGirl.generate(:name) }
    ip_address "0.0.0.0"

    # attrs-only
    first_name "Ed"
    last_name "Somethington"
    address1 "678 Some Lane"
    city "Some City"
    state "NY"
    zip "00000"
    card_type "Amex"
    card_number "4111111111111111"
    exp_month 12
    exp_year 2020
    csc "000"
    country "US"
  end

  factory :stripe_donor_card, class: DonorCard do
    stripe_token { ActiveSupport::TestCase.generate_stripe_card_token }
    is_active true
    email { FactoryGirl.generate(:email) }
    name { FactoryGirl.generate(:name) }
    ip_address "0.0.0.0"
  end
end
