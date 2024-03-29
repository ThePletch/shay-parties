class User < ApplicationRecord
  extend FriendlyId
  # Include default devise modules. Others available are:
  # :confirmable, :lockable, :timeoutable and :omniauthable
  devise :database_authenticatable, :registerable,
         :recoverable, :rememberable, :trackable, :validatable

  friendly_id :name, use: :history

  # events the user owns
  has_many :managed_events, class_name: "Event", dependent: :destroy
  has_many :addresses, -> { distinct }, through: :managed_events
  # events the user has rsvped to - some of these may be 'no' rsvps,
  # hence not calling this 'attended_events'
  has_many :attendances, as: :attendee, dependent: :destroy
  has_many :rsvped_events, source: :event, through: :attendances, class_name: "Event"
  has_many :comments, as: :creator, dependent: :destroy
  has_many :edited_comments, as: :editor, class_name: "Comment"
  has_many :poll_responses, as: :respondent, dependent: :destroy
  has_many :polls, through: :managed_events
  has_many :answered_polls, through: :poll_responses
  has_many :mailing_lists, dependent: :destroy

  def guest?
    false
  end

  private

  def should_generate_new_friendly_id?
    name_changed? || super
  end
end
