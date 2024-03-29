class Guest < ApplicationRecord
  has_many :attendances, as: :attendee, dependent: :destroy
  has_many :poll_responses, as: :respondent, dependent: :destroy
  has_many :comments, as: :creator, dependent: :destroy
  has_many :events, through: :attendances

  validates :name, presence: true
  validates :email, presence: true

  before_create :generate_guid

  def guest?
    true
  end

  private

  def generate_guid
    self.guid = SecureRandom.uuid
  end
end
