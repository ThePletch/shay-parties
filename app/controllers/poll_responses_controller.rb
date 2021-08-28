class PollResponsesController < ApplicationController
  before_action :authenticate_user!
  before_action :set_poll, only: :create

  def update
    @response = current_user.poll_responses.find(params[:id])
    if @response.update(poll_response_params)
      response_message = "Poll response updated."
      if rsvp = create_rsvp_if_not_exists(@response)
        response_message += " Automatically marked your RSVP as 'Maybe'."
      end

      message = {notice: response_message}
    else
      message = {alert: "Failed to update response: #{@response.errors}"}
    end

    redirect_to event_path(@response.event), message
  end

  def create
    # todo prevent multiple responses of the same type
    @response = @poll.responses.build(poll_response_params.merge(user: current_user))

    if @response.save
      response_message = "Responded to poll."
      if rsvp = create_rsvp_if_not_exists(@response)
        response_message += " Automatically marked your RSVP as 'Maybe'."
      end
      message = {notice: response_message}
    else
      message = {alert: "Failed to respond to poll: #{@response.errors}"}
    end

    redirect_to event_path(@poll.event), message
  end

  private

  def poll_response_params
    params.require(:poll_response).permit(:choice, :example_response)
  end

  def create_rsvp_if_not_exists(response)
    # we don't use a find_or_create_by so that this method returns nil if
    # an rsvp already exists
    unless rsvp = response.event.attendances.find_by(attendee_id: current_user.id)
      response.event.attendances.create(attendee: current_user, rsvp_status: "Maybe")
    end
  end

  def set_poll
    @poll = Poll.find(params[:poll_id])
  end
end
