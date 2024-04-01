class User < ApplicationRecord
  extend FriendlyId
  include Attendee

  # Include default devise modules. Others available are:
  # :confirmable, :lockable, :timeoutable and :omniauthable
  devise :database_authenticatable, :registerable,
         :recoverable, :rememberable, :trackable, :validatable

  friendly_id :name, use: :history

  # events the user owns
  has_many :managed_events, class_name: "Event", dependent: :destroy
  has_many :addresses, -> { distinct }, through: :managed_events

  has_many :polls, through: :managed_events
  has_many :mailing_lists, dependent: :destroy

  def guest?
    false
  end

  private

  def should_generate_new_friendly_id?
    name_changed? || super
  end
end
