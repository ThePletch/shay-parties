FactoryBot.define do
  factory :poll_option do
    poll
    choice { "Yeah" }
  end
end
