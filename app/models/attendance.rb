class Attendance < ActiveRecord::Base
  RSVP_TYPES = %w(Yes Maybe No)

  belongs_to :attendable, polymorphic: true
  belongs_to :invitable, polymorphic: true

  before_create :generate_token

  scope :going, -> { where(rsvp_status: "Yes") }
  scope :maybe, -> { where(rsvp_status: "Maybe") }
  scope :not_going, -> { where(rsvp_status: "No") }

  validates :rsvp_status, inclusion: {in: RSVP_TYPES, message: "Not a valid RSVP."}

  protected

  def generate_token
    self.invitation_token = loop do
      random_token = SecureRandom.urlsafe_base64(nil, false)
      break random_token unless Attendance.exists?(invitation_token: random_token)
    end
  end
end
