module CanHavePlusOnes
  extend ActiveSupport::Concern

  included do
    has_many :plus_ones, class_name: "Attendance", foreign_key: :attendance_id, dependent: :destroy
    accepts_nested_attributes_for :plus_ones, allow_destroy: true

    validates_each :plus_ones do |attendance, _attr, _value|
      # Nested attributes keep records marked for destruction in the association until
      # save; the UI can destroy and add in one submit, so only count active +1s.
      active_plus_ones = attendance.plus_ones.reject(&:marked_for_destruction?)
      kept_plus_one_count = active_plus_ones.count { |plus_one|
        attendance.persisted? && plus_one.persisted? && plus_one.attendance_id_in_database == attendance.id
      }
      adding_plus_ones = active_plus_ones.length > kept_plus_one_count

      if !attendance.event.allows_plus_ones? && adding_plus_ones
        attendance.errors.add(:base, :plus_ones_not_allowed)
      elsif attendance.event.has_plus_one_limit? && active_plus_ones.length > attendance.event.plus_one_max && adding_plus_ones
        attendance.errors.add(:base, :beyond_plus_one_limit)
      end
    end

    validates_associated :attendee, :plus_ones
  end
end
