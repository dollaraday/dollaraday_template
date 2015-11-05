FactoryGirl.define do
  sequence(:featured_on) { |i| i.days.from_now }
  sequence(:website_url) { |i| "http://somesite-#{i}.dev" }
  sequence(:nonprofit_name) { |i| "Foobar Charity #{i}" }
  sequence(:nonprofit_slug) { |i| "foobar-charity-#{i}" }
  sequence(:ein) { |i| "10-#{"%07d" % 5}" }

  factory :nonprofit do
    name { FactoryGirl.generate(:nonprofit_name) }
    slug { FactoryGirl.generate(:nonprofit_slug) }
    blurb "Helping foobars."
    description "Helping foobars everywhere."
    ein { FactoryGirl.generate(:ein) }
    website_url { FactoryGirl.generate(:website_url) }
    featured_on { FactoryGirl.generate(:featured_on) }
    is_public false

    after(:build) do |nonprofit|
      NetworkForGood::CreditCard.expects(:get_fee).with(nonprofit).at_least(0).returns({
        total_charge_amount: "1.04",
        total_add_fee: "0.04",
        total_deduct_fee: "0.0",
        tip_amount: "0.0",
        message: nil,
        error_details: nil,
        call_duration:"0.10916179999999999"
      })
    end
  end

  factory :valid_nonprofit, parent: :nonprofit do
    after(:build) do |nonprofit|
      NetworkForGood::CreditCard.expects(:get_fee).with(nonprofit).returns({})
    end
  end

  factory :invalid_nonprofit, parent: :nonprofit do
    after(:build) do |nonprofit|
      NetworkForGood::CreditCard.
        expects(:get_fee).with(nonprofit).
        raises(NetworkForGood::Base::UnexpectedResponse.new({error_details: {error_info: {err_data: "some error"}}}))
    end
  end

  factory :current_nonprofit, parent: :valid_nonprofit do
    is_public true
    featured_on Date.today
  end

  factory :past_nonprofit, parent: :valid_nonprofit do
    is_public true
    featured_on 2.weeks.ago
  end

  factory :upcoming_nonprofit, parent: :valid_nonprofit do
    is_public true
    featured_on 2.weeks.from_now
  end
end
