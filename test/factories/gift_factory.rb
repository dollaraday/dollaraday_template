FactoryGirl.define do
  factory :gift, class: Gift do
    association :donor, factory: :gift_donor, strategy: :build
    months_remaining 1
    start_on Date.today
    finish_on 30.days.from_now
    message "Hey here's a gift!"
  end

  factory :expiring_gift, parent: :gift do
    months_remaining 0
    start_on 25.days.ago
    finish_on 5.days.from_now
  end
end
