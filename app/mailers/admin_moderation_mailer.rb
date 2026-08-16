# frozen_string_literal: true

class AdminModerationMailer < ApplicationMailer
  def invite_send_restricted(admin, user, reason:)
    @admin = admin
    @user = user
    @reason = reason
    @admin_user_url = admin_user_url(user, locale: I18n.locale)

    mail(
      to: admin.email,
      subject: t(".subject", name: user.name)
    )
  end
end
