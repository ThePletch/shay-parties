class SignupSheetItemsController < ApplicationController
  before_action :require_user_or_guest_auth

  before_action :set_event, only: :create
  before_action :set_item, only: [:destroy, :update, :unclaim]
  before_action :set_unclaimed_item, only: [:claim]

  def update
    if @signup_sheet_item.update(signup_sheet_item_params)
      message = {notice: t('signup_sheet_item.updated')}
    else
      message = {alert: t('signup_sheet_item.updated_failed') + "#{@signup_sheet_item.errors.full_messages}"}
    end

    redirect_to event_path(@signup_sheet_item.event, guest_guid: params[:guest_guid]), message
  end

  def destroy
    if @signup_sheet_item.destroy
      message = {notice: t('signup_sheet_item.destroyed')}
    else
      message = {alert: t('signup_sheet_item.destroyed_failed')}
    end

    redirect_to event_path(@signup_sheet_item.event, guest_guid: params[:guest_guid]), message
  end

  def create
    if @event.owned_by?(@authenticated_user)
      params = signup_sheet_item_params.merge(requested: true)
    else
      params = signup_sheet_item_params.merge(attendee: @authenticated_user)
    end

    @signup_sheet_item = @event.signup_sheet_items.build(params)

    if @signup_sheet_item.save
      message = {notice: t('signup_sheet_item.created')}
    else
      message = {alert: t('signup_sheet_item.created_failed') + "#{@signup_sheet_item.errors.full_messages}"}
    end

    redirect_to event_path(@signup_sheet_item.event, guest_guid: params[:guest_guid]), message
  end

  def claim
    if @signup_sheet_item.update(attendee: @authenticated_user)
      message = {notice: t('signup_sheet_item.claimed')}
    else
      message = {alert: t('signup_sheet_item.claimed_failed') + "#{@signup_sheet_item.errors.full_messages}"}
    end

    redirect_to event_path(@signup_sheet_item.event, guest_guid: params[:guest_guid]), message
  end

  def unclaim
    if @signup_sheet_item.update(attendee: nil)
      message = {notice: t('signup_sheet_item.unclaimed')}
    else
      message = {alert: t('signup_sheet_item.unclaimed_failed') + "#{@signup_sheet_item.errors.full_messages}"}
    end

    redirect_to event_path(@signup_sheet_item.event, guest_guid: params[:guest_guid]), message
  end
  
  private

  def signup_sheet_item_params
    params.require(:signup_sheet_item).permit(:description)
  end

  def require_user_or_guest_auth
    unless @authenticated_user
      redirect_to new_user_session_path, alert: t('signup_sheet_item.rejection.unauthenticated')
      return
    end
  end

  def set_event
    @event = Event.friendly.find(params[:event_id])
  end

  def set_unclaimed_item
    @signup_sheet_item = SignupSheetItem.find(params[:id])
  end

  def set_item
    @signup_sheet_item = @authenticated_user.signup_sheet_items.find(params[:id])
  end
end
