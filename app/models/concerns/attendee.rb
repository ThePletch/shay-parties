module Attendee
  extend ActiveSupport::Concern

  included do
    # events the user has rsvped to - some of these may be 'no' rsvps,
    # hence not calling this 'attended_events'
    has_many :attendances, as: :attendee, dependent: :destroy
    has_many :poll_responses, as: :respondent, dependent: :destroy
    has_many :answered_polls, through: :poll_responses
    has_many :rsvped_events, source: :event, through: :attendances, class_name: "Event"
    has_many :comments, as: :creator, dependent: :destroy
    has_many :edited_comments, as: :editor, class_name: "Comment"
    has_many :signup_sheet_items, as: :attendee, dependent: :destroy
  end

  def attending?(event, expected_rsvp = nil)
    expected_properties = {event: event}

    if expected_rsvp
      expected_properties[:rsvp_status] = expected_rsvp
    end

    attendances.where(expected_properties).any?
  end
end
