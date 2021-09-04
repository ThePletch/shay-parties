class User < ApplicationRecord
  # Include default devise modules. Others available are:
  # :confirmable, :lockable, :timeoutable and :omniauthable
  devise :database_authenticatable, :registerable,
         :recoverable, :rememberable, :trackable, :validatable

  # users can leave comments
  acts_as_commontator
  acts_as_voter

  # events the user owns
  has_many :managed_events, class_name: "Event", dependent: :destroy
  has_many :addresses, -> { distinct }, through: :managed_events
  # events the user has rsvped to - some of these may be 'no' rsvps,
  # hence not calling this 'attended_events'
  has_many :rsvped_events, through: :attendances, class_name: "Event"
  has_many :attendances, as: :attendee, dependent: :destroy
  has_many :poll_responses, as: :respondent, dependent: :destroy
  has_many :polls, through: :managed_events
  has_many :answered_polls, through: :poll_responses
  has_many :mailing_lists, dependent: :destroy
end
