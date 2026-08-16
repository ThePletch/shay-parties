FactoryBot.define do
  factory :user do
    sequence(:email) {|x| "email#{x}@steve-pletcher.com" }
    sequence(:name) {|x| "User #{x}"}
    password { "wordpass" }
    password_confirmation { "wordpass" }
    confirmed_at { Time.current }
    role { "user" }

    trait :unconfirmed do
      confirmed_at { nil }
      after(:build) { |user| user.skip_confirmation_notification! }
    end

    trait :admin do
      role { "admin" }
    end

    trait :superadmin do
      role { "superadmin" }
    end

    trait :suspended do
      role { "suspended" }
    end

    trait :banned do
      role { "banned" }
    end
  end

  factory :banned_email do
    sequence(:email) { |x| "banned#{x}@example.com" }
    reason { "spam" }
    association :banned_by, factory: [:user, :admin]
  end
end
