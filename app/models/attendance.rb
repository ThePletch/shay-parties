class Attendance < ActiveRecord::Base
  RSVP_TYPES = %w(Yes Maybe No)

  belongs_to :event
  belongs_to :user

  scope :going, -> { where(rsvp_status: "Yes") }
  scope :maybe, -> { where(rsvp_status: "Maybe") }
  scope :not_going, -> { where(rsvp_status: "No") }

  validates :rsvp_status, inclusion: {in: RSVP_TYPES, message: "Not a valid RSVP."}
end
