module CanBeAPlusOne
  extend ActiveSupport::Concern

  included do
    belongs_to :parent_attendance, class_name: "Attendance",
                                   foreign_key: :attendance_id,
                                   optional: true,
                                   inverse_of: :plus_ones
    validate :same_event_as_parent_event
  end

  def same_event_as_parent_event
    return unless parent_attendance.present?

    if parent_attendance.event_id != event_id
      errors.add(:base, :parent_event_is_different)
    end
  end
end
