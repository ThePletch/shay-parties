class CohostsController < ApplicationController
  before_action :set_hosted_event, :set_target_user, only: :create

  def create
    @cohost = @event.cohosts.build(user: @target_user)

    if @cohost.save
      redirect_to @event, notice: t('cohost.created')
    else
      redirect_to @event, alert: t('cohost.failed')
    end
  end

  def destroy
    @cohost = Cohost.find(params[:id])
    raise ActiveRecord::RecordNotFound unless current_user.managed_events.exists?(id: @cohost.event_id)

    if @cohost.destroy
      redirect_to @cohost.event, notice: t('cohost.destroyed')
    else
      redirect_to @cohost.event, alert: t('cohost.failed_destroy')
    end
  end

  private

  def set_hosted_event
    @event = current_user.managed_events.friendly.find(params[:event_id])
  end

  def set_target_user
    @target_user = User.find(params[:user_id])
  end
end
