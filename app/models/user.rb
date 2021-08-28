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
  has_many :poll_responses, dependent: :destroy
  has_many :polls, through: :poll_responses
  has_many :mailing_lists, dependent: :destroy

  validate :only_one_default_host

  def default_host?
    default_host
  end

  # if we haven't set the default host yet, default to the first user in the system
  # until we set the default host.
  def self.default_host
    User.find_by(default_host: true) || User.first
  end

  private

  def only_one_default_host
    if default_host? && User.where(default_host: true).where.not(id: id).exists?
      errors.add(:default_host, "Cannot have more than one default host.")
    end
  end
end
