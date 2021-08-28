FactoryBot.define do
  factory :poll_response do
    respondent factory: :user
    poll
    choice { "Yeah" }
    example_response { false }

    factory :guest_response do
      respondent factory: :guest
    end
  end
end
