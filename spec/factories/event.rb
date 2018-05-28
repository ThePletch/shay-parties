FactoryBot.define do
  factory :event do
    address
    owner factory: :user
    start_time { Time.current - 1.day }
    end_time { Time.current }
  end
end
