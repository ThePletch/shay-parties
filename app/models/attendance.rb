class Attendance < ActiveRecord::Base
  RSVP_TYPES = %w(Yes Maybe No)

  after_destroy :clean_up_guest_on_destroy
  after_destroy :clean_up_poll_responses

  belongs_to :event
  belongs_to :attendee, polymorphic: true
  belongs_to :user, -> { where(attendances: { attendee_type: "User" }) }, foreign_key: :attendee_id
  belongs_to :guest, -> { where(attendances: { attendee_type: "Guest" }) }, foreign_key: :attendee_id
  # Plus-one associations
  belongs_to :parent_attendance, class_name: "Attendance",
                                 foreign_key: :attendance_id,
                                 optional: true,
                                 inverse_of: :plus_ones
  has_many :plus_ones, class_name: "Attendance", foreign_key: :attendance_id, dependent: :destroy
  accepts_nested_attributes_for :attendee, allow_destroy: true
  accepts_nested_attributes_for :plus_ones, allow_destroy: true

  scope :going, -> { where(rsvp_status: "Yes") }
  scope :maybe, -> { where(rsvp_status: "Maybe") }
  scope :not_going, -> { where(rsvp_status: "No") }

  validates :event, presence: true
  validates :attendee, presence: true
  validate :same_event_as_parent_event
  validates :rsvp_status, inclusion: {in: RSVP_TYPES}
  validates :attendee_type, exclusion: {in: ["User"]}, if: -> { attendance_id.present? }
  validates_associated :attendee, :plus_ones

  def attending?
    %w(Yes Maybe).include?(rsvp_status)
  end

  def build_attendee(params)
    self.attendee = attendee_type.constantize.new(params)
  end

  private

  def same_event_as_parent_event
    return unless parent_attendance.present?

    if parent_attendance.event_id != event_id
      errors.add(:attendance_id, :parent_event_is_different)
    end
  end

  def clean_up_guest_on_destroy
    self.attendee.destroy! if self.attendee.is_a?(Guest)
  end

  def clean_up_poll_responses
    self.attendee.poll_responses.joins(:poll).where(polls: {event_id: self.event.id}).destroy_all
  end
end
