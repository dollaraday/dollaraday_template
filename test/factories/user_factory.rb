
FactoryGirl.define do
  sequence(:name) { |i| "Person#{i}" }
  factory :user do
    name { FactoryGirl.generate(:name) }
    email { FactoryGirl.generate(:email) }
    password "password"
  end

  factory :admin, parent: :user do
    is_admin true
  end
end
