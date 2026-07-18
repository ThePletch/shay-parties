module CanHavePlusOnes
  extend ActiveSupport::Concern

  included do
    has_many :plus_ones, class_name: "Attendance", foreign_key: :attendance_id, dependent: :destroy
    accepts_nested_attributes_for :plus_ones, allow_destroy: true
    
    validates_each :plus_ones do |attendance, attr, value|
      if !attendance.event.allows_plus_ones? && attendance.plus_ones.any?
        attendance.errors.add(:base, :plus_ones_not_allowed)
      elsif attendance.event.has_plus_one_limit? && attendance.plus_ones.length > attendance.event.plus_one_max
        attendance.errors.add(:base, :beyond_plus_one_limit)
      end
    end

    validates_associated :attendee, :plus_ones
  end
end
