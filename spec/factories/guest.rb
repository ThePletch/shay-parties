FactoryBot.define do
  factory :guest do
    sequence(:email) {|x| "guest-email#{x}@steve-pletcher.com" }
    sequence(:name) {|x| "Guest #{x}" }
  end
end
