# frozen_string_literal: true

class EmailDeliveryEvent < ApplicationRecord
  EVENT_TYPES = %w[bounce complaint].freeze
  HARD_BOUNCE_TYPE = "Permanent"

  belongs_to :invite_send, optional: true
  belongs_to :user

  validates :recipient_email, :event_type, presence: true
  validates :event_type, inclusion: { in: EVENT_TYPES }

  scope :hard_bounces, -> { where(event_type: "bounce", bounce_type: HARD_BOUNCE_TYPE) }

  def hard_bounce?
    event_type == "bounce" && bounce_type == HARD_BOUNCE_TYPE
  end

  def complaint?
    event_type == "complaint"
  end
end
