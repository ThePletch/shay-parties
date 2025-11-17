module CanHavePlusOnes
  extend ActiveSupport::Concern

  included do
    has_many :plus_ones, class_name: "Attendance", foreign_key: :attendance_id, dependent: :destroy
    accepts_nested_attributes_for :plus_ones, allow_destroy: true
    validate :within_plus_one_limit
    validates_associated :attendee, :plus_ones
  end

  def within_plus_one_limit
    return if event.plus_one_max < 0

    if plus_ones.length > event.plus_one_max
      errors.add(:too_many_plus_ones)
    end
  end


end
