class Event < ApplicationRecord
  include Ownable

  acts_as_attendable :attendances, by: :users

  # events can be commented on
  acts_as_commontable dependent: :destroy

  has_many :polls, dependent: :destroy
  has_one :address

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
