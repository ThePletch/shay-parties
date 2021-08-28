FactoryBot.define do
  factory :address do
    sequence(:street) {|n| "#{n} Main Street" }
    street2 { "Unit 1" }
    city { "Albuquerque" }
    state { "NM" }
    zip_code { "12354" }

    trait :with_event do
      event
    end
  end
end
