FactoryBot.define do
  factory :user do
    sequence(:email) {|x| "email#{x}@steve-pletcher.com" }
    password { "wordpass" }
    password_confirmation { "wordpass" }
  end
end
