FactoryBot.define do
  factory :comment do
    event
    creator factory: :user
    body { "This party looks great!" }
  end
end
