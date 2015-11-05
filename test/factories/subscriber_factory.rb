FactoryGirl.define do
  sequence(:email) { |n| "somethington-#{n}@test.com" }

  factory :subscriber do
    email { FactoryGirl.generate(:email) }
    name { FactoryGirl.generate(:name) }
    subscribed_at 3.months.ago
    ip_address "1.1.1.1"
  end

  factory :unsubscribed_subscriber, parent: :subscriber do
    unsubscribed_at 1.month.ago
  end

  factory :donor_subscriber, parent: :subscriber do
    email nil
    name nil
  end

end
