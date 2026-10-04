# frozen_string_literal: true

class EventInviteMailer < ApplicationMailer
  def invite(event:, host:, recipient_email:, message:)
    @event = event
    @host = host
    @message = message.to_s.strip
    @event_url = event_url(event, locale: I18n.locale)

    mail(
      to: recipient_email,
      reply_to: host.email,
      subject: t(".subject", title: event.title, host: host.name)
    )
  end
end
