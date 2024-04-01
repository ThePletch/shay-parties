class Guest < ApplicationRecord
  include Attendee

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
