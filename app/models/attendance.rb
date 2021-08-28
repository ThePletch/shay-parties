class Attendance < ActiveRecord::Base
  RSVP_TYPES = %w(Yes Maybe No)

  after_destroy :clean_up_guest_on_destroy

  belongs_to :event
  belongs_to :attendee, polymorphic: true
  accepts_nested_attributes_for :attendee, allow_destroy: true

  scope :going, -> { where(rsvp_status: "Yes") }
  scope :maybe, -> { where(rsvp_status: "Maybe") }
  scope :not_going, -> { where(rsvp_status: "No") }

  validates :rsvp_status, inclusion: {in: RSVP_TYPES, message: "Not a valid RSVP."}
  validates_associated :attendee

  private

  def clean_up_guest_on_destroy
    self.attendee.destroy if self.attendee.is_a?(Guest)
  end
end
