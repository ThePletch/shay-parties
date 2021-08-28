FactoryBot.define do
  factory :attendance do
    attendee factory: :user
    rsvp_status { "Yes" }
  end

  factory :guest_attendance, class: 'Attendance' do
    attendee factory: :guest
    rsvp_status { "Yes" }
  end
end
