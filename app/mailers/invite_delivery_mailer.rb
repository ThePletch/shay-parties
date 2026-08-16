# frozen_string_literal: true

class InviteDeliveryMailer < ApplicationMailer
  def bounce_warning(user, recipient_email:, remaining:)
    @user = user
    @recipient_email = recipient_email
    @remaining = remaining
    @allowance = User::HARD_BOUNCE_ALLOWANCE

    mail(
      to: user.email,
      subject: t(".subject")
    )
  end

  def restricted(user, reason:)
    @user = user
    @reason = reason

    mail(
      to: user.email,
      subject: t(".subject")
    )
  end
end
