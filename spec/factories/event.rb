FactoryBot.define do
  factory :event do
    address
    owner factory: :user
    sequence(:title) {|n| "Mambo Number #{n}" }
    start_time { Time.current - 1.day }
    end_time { Time.current }
  end
end
