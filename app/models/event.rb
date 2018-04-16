class Event < ApplicationRecord
  acts_as_attendable :attendances, by: :users

  # events can be commented on
  acts_as_commentable dependent: :destroy

  has_one :address
  belongs_to :owner, class_name: "User", foreign_key: :user_id

  validate :ends_after_it_starts

  def owned_by?(user)
    user.id == owner.id
  end

  private

  def ends_after_it_starts
    unless end_time > start_time
      errors.add(:end_time, "End time must be after start time.")
    end
  end
end
