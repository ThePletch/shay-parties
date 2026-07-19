FactoryBot.define do
  factory :user do
    sequence(:email) {|x| "email#{x}@steve-pletcher.com" }
    sequence(:name) {|x| "User #{x}"}
    password { "wordpass" }
    password_confirmation { "wordpass" }
    confirmed_at { Time.current }

    trait :unconfirmed do
      confirmed_at { nil }
      after(:build) { |user| user.skip_confirmation_notification! }
    end
  end
end
