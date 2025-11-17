module CanBeAPlusOne
  extend ActiveSupport::Concern

  included do
    belongs_to :parent_attendance, class_name: "Attendance",
                                   foreign_key: :attendance_id,
                                   optional: true,
                                   inverse_of: :plus_ones
    validate :same_event_as_parent_event
    validate :parent_within_plus_one_limit
  end

  def same_event_as_parent_event
    return unless parent_attendance.present?

    if parent_attendance.event_id != event_id
      errors.add(:attendance_id, :parent_event_is_different)
    end
  end

  def parent_within_plus_one_limit
    return unless parent_attendance.present?
    return if event.plus_one_max < 0

    if parent_attendance.plus_ones.where.not(id: self.id).length >= event.plus_one_max
      errors.add(:attendance_id, :too_many_plus_ones)
    end
  end


end
