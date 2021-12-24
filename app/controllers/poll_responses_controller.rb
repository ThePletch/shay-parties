class PollResponsesController < ApplicationController
  before_action :set_poll, only: :create
  before_action :set_response, only: [:update, :destroy]

  def update
    if @response.update(poll_response_params)

      if rsvp = create_rsvp_if_not_exists(@response)
        response_message = t('poll_response.updated_automaybe')
      else
        response_message = t('poll_response.updated')
      end

      message = {notice: response_message}
    else
      message = {alert: t('poll_response.updated_failed') + "#{@response.errors}"}
    end

    redirect_to event_path(@response.event, guest_guid: params[:guest_guid]), message
  end

  def destroy
    if @response.destroy
      message = {notice: t('poll_response.destroyed')}
    else
      message = {alert: t('poll_response.destroyed_failed')}
    end

    redirect_to event_path(@response.event, guest_guid: params[:guest_guid]), message
  end

  def create
    # todo prevent multiple responses of the same type
    if current_user
      @response = @poll.responses.build(poll_response_params.merge(respondent: current_user))
    elsif params[:guest_guid].present? and guest = Guest.find_by(guid: params[:guest_guid])
      @response = @poll.responses.build(poll_response_params.merge(respondent: guest))
    else
      redirect_to new_user_session_path, alert: t('poll_response.rejection.unauthenticated')
      return
    end


    if @response.save
      if rsvp = create_rsvp_if_not_exists(@response)
        response_message = t('poll_response.created_automaybe')
      else
        response_message = t('poll_response.created')
      end
      message = {notice: response_message}
    else
      message = {alert: t('poll_response.created_failed') + "#{@response.errors}"}
    end

    redirect_to event_path(@poll.event, guest_guid: params[:guest_guid]), message
  end

  private

  def set_response
    if current_user
      @response = current_user.poll_responses.find(params[:id])
    elsif params[:guest_guid].nil?
      redirect_to new_user_session_path
    else
      if guest = Guest.find_by(guid: params[:guest_guid])
        @response = guest.poll_responses.find(params[:id])
      else
        redirect_to new_user_session_path, notice: t('guest.rejection.bad_id')
      end
    end
  end

  def poll_response_params
    params.require(:poll_response).permit(:choice, :example_response)
  end

  def respondent_params
    params.require(:respondent).permit(:name, :email)
  end

  def create_rsvp_if_not_exists(response)
    # we don't use a find_or_create_by so that this method returns nil if
    # an rsvp already exists
    unless rsvp = response.event.attendances.find_by(attendee: response.respondent)
      response.event.attendances.create(attendee: response.respondent, rsvp_status: "Maybe")
    end
  end

  def set_poll
    @poll = Poll.find(params[:poll_id])
  end
end
