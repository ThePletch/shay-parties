# frozen_string_literal: true

class InviteSend < ApplicationRecord
  DAILY_LIMIT = 50

  class BatchRejected < StandardError
    attr_reader :message_key, :options

    def initialize(message_key, options = {})
      @message_key = message_key
      @options = options
      super(I18n.t(message_key, **options))
    end
  end

  belongs_to :user
  belongs_to :event
  has_many :email_delivery_events, dependent: :nullify

  validates :recipient_email, presence: true

  def self.recent_count_for(user)
    where(user_id: user.id).where("created_at > ?", 24.hours.ago).count
  end

  def self.send_batch!(event:, user:, message:, recipients:)
    raise BatchRejected.new("invite.rejection.restricted") if user.invite_send_restricted?
    raise BatchRejected.new("invite.rejection.unconfirmed") unless user.confirmed?
    raise BatchRejected.new("invite.rejection.not_owner") unless event.owned_by?(user)

    normalized = normalize_recipients(recipients)
    raise BatchRejected.new("invite.rejection.no_recipients") if normalized.empty?
    raise BatchRejected.new("invite.rejection.batch_too_large", limit: DAILY_LIMIT) if normalized.size > DAILY_LIMIT

    used = recent_count_for(user)
    remaining = DAILY_LIMIT - used
    if normalized.size > remaining
      raise BatchRejected.new("invite.rejection.over_quota", remaining: remaining, limit: DAILY_LIMIT)
    end

    invalid = normalized.reject { |recipient| recipient[:email].match?(URI::MailTo::EMAIL_REGEXP) }
    if invalid.any?
      raise BatchRejected.new(
        "invite.rejection.invalid_emails",
        emails: invalid.map { |recipient| recipient[:email] }.join(", ")
      )
    end

    normalized.map { |recipient| deliver_one!(event:, user:, message:, recipient:) }
  end

  def self.normalize_recipients(recipients)
    seen = {}
    Array(recipients).filter_map do |recipient|
      email = recipient[:email].to_s.strip.downcase
      next if email.blank?
      next if seen[email]

      seen[email] = true
      { name: recipient[:name].to_s.strip, email: email }
    end
  end
  private_class_method :normalize_recipients

  def self.deliver_one!(event:, user:, message:, recipient:)
    record = create!(user:, event:, recipient_email: recipient[:email])
    mailer = EventInviteMailer.invite(
      event: event,
      host: user,
      recipient_name: recipient[:name],
      recipient_email: recipient[:email],
      message: message
    )
    message_id = Ses::InviteDelivery.deliver!(
      mailer,
      tags: {
        "user_id" => user.id.to_s,
        "invite_send_id" => record.id.to_s,
      }
    )
    record.update!(ses_message_id: message_id)
    record
  rescue StandardError
    record.destroy if record&.persisted?
    raise
  end
  private_class_method :deliver_one!
end
