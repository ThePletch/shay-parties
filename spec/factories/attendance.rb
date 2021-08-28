FactoryBot.define do
  factory :attendance do
    event
    attendee factory: :user
    rsvp_status { "Yes" }

    factory :guest_attendance do
      attendee factory: :guest
    end
  end
end
