FactoryBot.define do
  factory :user do
    sequence(:email) {|x| "email#{x}@steve-pletcher.com" }
    sequence(:name) {|x| "User #{x}"}
    password { "wordpass" }
    password_confirmation { "wordpass" }
  end
end
