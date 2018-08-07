class User < ApplicationRecord
  # Include default devise modules. Others available are:
  # :confirmable, :lockable, :timeoutable and :omniauthable
  devise :database_authenticatable, :registerable,
         :recoverable, :rememberable, :trackable, :validatable

  # users can leave comments
  acts_as_commentator

  # events the user owns
  has_many :managed_events, class_name: "Event"
  # events the user has rsvped to - some of these may be 'no' rsvps,
  # hence not calling this 'attended_events'
  has_many :rsvped_events, through: :attendances, class_name: "Event"
  has_many :attendances, as: :invitable
  has_many :poll_responses
  has_many :polls
  has_many :mailing_lists

  def creator?
    role == "creator"
  end
end
