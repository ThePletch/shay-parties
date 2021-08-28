FactoryBot.define do
  factory :poll_response do
    user
    poll
    choice { "Yeah" }
    example_response { false }
  end
end
