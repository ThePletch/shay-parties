# frozen_string_literal: true

class EventInviteMailer < ApplicationMailer
  def invite(event:, host:, recipient_name:, recipient_email:, message:)
    @event = event
    @host = host
    @recipient_name = recipient_name
    @message = message
    @event_url = event_url(event, locale: I18n.locale)

    mail(
      to: recipient_email,
      reply_to: host.email,
      subject: t(".subject", title: event.title, host: host.name)
    )
  end
end
