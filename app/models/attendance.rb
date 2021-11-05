class Attendance < ActiveRecord::Base
  RSVP_TYPES = %w(Yes Maybe No)

  after_destroy :clean_up_guest_on_destroy
  after_destroy :clean_up_poll_responses

  belongs_to :event
  belongs_to :attendee, polymorphic: true
  accepts_nested_attributes_for :attendee, allow_destroy: true

  scope :going, -> { where(rsvp_status: "Yes") }
  scope :maybe, -> { where(rsvp_status: "Maybe") }
  scope :not_going, -> { where(rsvp_status: "No") }

  validates :event, presence: true
  validates :rsvp_status, inclusion: {in: RSVP_TYPES, message: "Not a valid RSVP."}
  validates_associated :attendee

  def attending?
    %w(Yes Maybe).include?(rsvp_status)
  end

  private

  def clean_up_guest_on_destroy
    self.attendee.destroy! if self.attendee.is_a?(Guest)
  end

  def clean_up_poll_responses
    self.attendee.poll_responses.joins(:poll).where(polls: {event_id: self.event.id}).destroy_all
  end
end
