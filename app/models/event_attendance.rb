class EventAttendance < ActiveRecord::Base
  belongs_to :attendable, polymorphic: true
  belongs_to :invitable, polymorphic: true
  
  before_create :generate_token

  protected

    def generate_token
      self.invitation_token = loop do
        random_token = SecureRandom.urlsafe_base64(nil, false)
        break random_token unless EventAttendance.exists?(invitation_token: random_token)
      end
    end
  
end