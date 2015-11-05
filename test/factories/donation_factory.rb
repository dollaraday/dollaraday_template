FactoryGirl.define do
  factory :scheduled_donation, class: Donation do
    association :donor, factory: :nfg_donor
    donor_card { donor.card }
    scheduled_at 1.day.from_now

    before(:create) do |d|
      # Create enough nonprofits that this donation could execute when necessary
      Donation::NUMBER_OF_NONPROFITS.times do |i|
        date = d.scheduled_at.to_date + i
        Nonprofit.where(featured_on: date).first.presence || FactoryGirl.create(:upcoming_nonprofit, featured_on: date)
      end
    end
  end

  factory :executed_donation, parent: :scheduled_donation do
    scheduled_at 20.days.ago
    executed_at 20.days.ago
    amount 30.00
    nfg_charge_id "123abc"

    before(:create) do |d|
      # Create the nonprofits for which this donation was executed
      Donation::NUMBER_OF_NONPROFITS.times do |i|
        date = d.scheduled_at.to_date + i
        d.nonprofits << Nonprofit.where(featured_on: date).first!
      end
    end
  end

  factory :failed_donation, parent: :scheduled_donation do
    scheduled_at Time.now
    last_failure "UnexpectedResponse blah blah"
    failed_at Time.now
  end


  factory :failed_gift_donation, parent: :failed_donation do
    last_failure "Donation::ExpiredGift"
  end
end
