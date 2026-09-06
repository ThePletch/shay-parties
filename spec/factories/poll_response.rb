FactoryBot.define do
  factory :poll_response do
    respondent factory: :user

    transient do
      poll { nil }
    end

    poll_option { association :poll_option, poll: (poll || association(:poll)) }

    factory :guest_response do
      respondent factory: :guest
    end
  end
end
