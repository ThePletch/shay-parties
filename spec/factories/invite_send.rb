FactoryBot.define do
  factory :invite_send do
    user
    event
    sequence(:recipient_email) { |n| "guest#{n}@example.com" }
    sequence(:ses_message_id) { |n| "ses-message-#{n}" }
  end

  factory :email_delivery_event do
    invite_send
    user { invite_send.user }
    recipient_email { invite_send.recipient_email }
    event_type { "bounce" }
    bounce_type { "Permanent" }
    sequence(:ses_message_id) { |n| "ses-event-#{n}" }
  end
end
