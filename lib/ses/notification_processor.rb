# frozen_string_literal: true

module Ses
  class NotificationProcessor
    def self.process(message)
      new(message).process
    end

    def initialize(message)
      @payload = parse(message)
    end

    def process
      case event_type
      when "Bounce"
        process_bounce
      when "Complaint"
        process_complaint
      end
    end

    private

    attr_reader :payload

    def parse(message)
      message.is_a?(String) ? JSON.parse(message) : message
    end

    def event_type
      payload["eventType"] || payload["notificationType"]
    end

    def mail
      payload["mail"] || {}
    end

    def ses_message_id
      mail["messageId"]
    end

    def invite_send
      @invite_send ||= begin
        tagged_id = tag_value("invite_send_id")
        InviteSend.find_by(id: tagged_id) || InviteSend.find_by(ses_message_id: ses_message_id)
      end
    end

    def user
      @user ||= invite_send&.user || User.find_by(id: tag_value("user_id"))
    end

    def tag_value(name)
      tags = mail["tags"] || {}
      Array(tags[name] || tags[name.to_s]).first
    end

    def process_bounce
      bounce = payload["bounce"] || {}
      bounce_type = bounce["bounceType"]
      recipients = Array(bounce["bouncedRecipients"]).presence || [{ "emailAddress" => invite_send&.recipient_email }]

      recipients.each do |recipient|
        email = recipient["emailAddress"].to_s.downcase.presence
        next if email.blank? || user.nil?

        record = record_event!(
          event_type: "bounce",
          bounce_type: bounce_type,
          recipient_email: email
        )
        next unless record&.hard_bounce?

        apply_hard_bounce!(email)
      end
    end

    def process_complaint
      complaint = payload["complaint"] || {}
      recipients = Array(complaint["complainedRecipients"]).presence || [{ "emailAddress" => invite_send&.recipient_email }]

      recipients.each do |recipient|
        email = (recipient["emailAddress"] || recipient["email"]).to_s.downcase.presence
        next if email.blank? || user.nil?

        record = record_event!(
          event_type: "complaint",
          bounce_type: nil,
          recipient_email: email
        )
        next unless record

        apply_complaint!
      end
    end

    def record_event!(event_type:, bounce_type:, recipient_email:)
      EmailDeliveryEvent.create!(
        invite_send: invite_send,
        user: user,
        recipient_email: recipient_email,
        event_type: event_type,
        bounce_type: bounce_type,
        ses_message_id: ses_message_id,
        raw_payload: payload
      )
    rescue ActiveRecord::RecordNotUnique
      nil
    end

    def apply_hard_bounce!(recipient_email)
      remaining = user.remaining_hard_bounce_allowance
      if remaining <= 0
        restrict_and_notify!(reason: "bounce_limit")
      else
        InviteDeliveryMailer.bounce_warning(
          user,
          recipient_email: recipient_email,
          remaining: remaining
        ).deliver_now
      end
    end

    def apply_complaint!
      restrict_and_notify!(reason: "complaint")
    end

    def restrict_and_notify!(reason:)
      already_restricted = user.invite_send_restricted?
      user.restrict_invite_sends!(reason: reason)
      return if already_restricted

      InviteDeliveryMailer.restricted(user, reason: reason).deliver_now
      User.admins.find_each do |admin|
        AdminModerationMailer.invite_send_restricted(admin, user, reason: reason).deliver_now
      end
    end
  end
end
