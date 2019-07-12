class Event < ApplicationRecord
  include Ownable

  has_many :attendances
  has_many :attendees, through: :attendances, class_name: 'User'

  # events can be commented on
  acts_as_commontable dependent: :destroy

  has_many :polls, dependent: :destroy
  belongs_to :address

  accepts_nested_attributes_for :address, update_only: true

  validate :ends_after_it_starts
  validates_associated :address

  private

  def ends_after_it_starts
    unless end_time > start_time
      errors.add(:end_time, "End time must be after start time.")
    end
  end
end
