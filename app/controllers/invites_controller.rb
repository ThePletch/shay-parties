# frozen_string_literal: true

class InvitesController < ApplicationController
  before_action :authenticate_user!
  before_action :set_owned_event
  before_action :require_confirmed_email!
  before_action :verify_turnstile, only: :create

  def new
    @message = ""
    @recipients = [{}]
    @quota_remaining = current_user.remaining_invite_quota
  end

  def preview
    assign_form_from_params
    recipient = preview_recipient
    unless recipient
      render plain: t("invite.preview.need_recipient"), status: :unprocessable_content
      return
    end

    mail = EventInviteMailer.invite(
      event: @event,
      host: current_user,
      recipient_name: recipient[:name],
      recipient_email: recipient[:email],
      message: @message
    )
    html = mail.html_part&.decoded || mail.body.decoded
    render html: html.html_safe
  end

  def create
    assign_form_from_params

    if current_user.invite_send_restricted?
      flash.now[:alert] = t("invite.rejection.restricted")
      render :new, status: :unprocessable_content
      return
    end

    sent = InviteSend.send_batch!(
      event: @event,
      user: current_user,
      message: @message,
      recipients: selected_recipients
    )
    redirect_to event_path(@event), notice: t("invite.sent", count: sent.size)
  rescue InviteSend::BatchRejected => e
    flash.now[:alert] = e.message
    @recipients = @recipients.presence || [{}]
    @quota_remaining = current_user.remaining_invite_quota
    render :new, status: :unprocessable_content
  end

  private

  def set_owned_event
    @event = current_user.managed_events.friendly.find(params[:event_id])
  end

  def require_confirmed_email!
    return if current_user.confirmed?

    redirect_to event_path(@event), alert: t("invite.rejection.unconfirmed")
  end

  def verify_turnstile
    token = params["cf-turnstile-response"]
    return if Cloudflare::Turnstile.verify(token, remote_ip: request.remote_ip)

    assign_form_from_params
    @quota_remaining = current_user.remaining_invite_quota
    flash.now[:alert] = t("turnstile.failed")
    render :new, status: :unprocessable_content
  end

  def assign_form_from_params
    @message = params[:message].to_s
    @recipients = recipient_params
    @quota_remaining = current_user.remaining_invite_quota
  end

  def recipient_params
    raw = params[:recipients]
    return [{}] if raw.blank?

    values = case raw
             when ActionController::Parameters then raw.to_unsafe_h.values
             when Hash then raw.values
             else Array(raw)
             end

    parsed = values.filter_map do |entry|
      hash = entry.to_h.symbolize_keys
      next if hash[:_destroy].to_s == "1"

      { name: hash[:name], email: hash[:email], selected: hash[:selected] }
    end
    parsed.presence || [{}]
  end

  def selected_recipients
    recipient_params.select do |recipient|
      selected = recipient[:selected]
      selected.nil? || ActiveModel::Type::Boolean.new.cast(selected)
    end
  end

  def preview_recipient
    recipient_params.find { |recipient| recipient[:email].to_s.strip.present? }
  end
end
