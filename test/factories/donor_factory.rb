FactoryGirl.define do
  sequence(:guid) { |n| SecureRandom.hex(16) }

  factory :nfg_donor, class: Donor do
    association :card, factory: :nfg_donor_card, strategy: :build
    association :subscriber, factory: :donor_subscriber, strategy: :build
    started_on { Time.zone.now.to_date }
    public_name "Ed S"
    guid { FactoryGirl.generate(:guid) }
  end

  factory :stripe_donor, class: Donor do
    association :card, factory: :stripe_donor_card, strategy: :build
    association :subscriber, factory: :donor_subscriber, strategy: :build
    started_on { Time.zone.now.to_date }
    public_name "Ed S"
    guid { FactoryGirl.generate(:guid) }
  end


  factory :gift_donor, parent: :stripe_donor do
    # NB using :subscriber on purpose -- we pass in Subscriber#name/email thru controller intentionally.
    association :subscriber, factory: :subscriber, strategy: :build
  end

  factory :active_cancelled_donor, parent: :stripe_donor do
    after(:create) do |donor|
      executed_donation = FactoryGirl.create(:executed_donation, donor_card: donor.card, donor: donor, scheduled_at: 20.days.ago, executed_at: 20.days.ago)
      cancelled_donation = FactoryGirl.create(:scheduled_donation, donor_card: donor.card, donor: donor, scheduled_at: 30.days.since(executed_donation.executed_at), cancelled_at: 30.days.since(executed_donation.executed_at))
      donor.update_column(:cancelled_at, 30.days.since(executed_donation.executed_at))
    end
  end

  # Last donation was 40 days ago
  # Cancelled 40 days ago
  # Finished 10 days ago
  factory :inactive_cancelled_donor, parent: :stripe_donor do
    after(:create) do |donor|
      executed_donation  = FactoryGirl.create(:executed_donation, donor_card: donor.card, donor: donor, scheduled_at: 40.days.ago, executed_at: 40.days.ago)
      cancelled_donation = FactoryGirl.create(:scheduled_donation, donor_card: donor.card, donor: donor, scheduled_at: 30.days.since(executed_donation.executed_at), cancelled_at: executed_donation.executed_at)
      donor.update_column(:cancelled_at, executed_donation.executed_at)
      donor.update_column(:finished_on, executed_donation.executed_at + 30.days)
    end
  end

  factory :failed_donor, parent: :stripe_donor do
    # TODO
    # TODO
    # TODO
  end

end
