class PollResponsesController < ApplicationController
  before_action :set_poll, only: :create
  before_action :authenticate_user!

  def update
    @response = current_user.poll_responses.find(params[:id])
    if @response.update(poll_response_params)
      message = { notice: "Poll response updated." }
    else
      message = { alert: "Failed to update response: #{@response.errors}" }
    end

    redirect_to event_path(@response.event), message
  end

  def create
    # todo prevent multiple responses of the same type
    @response = @poll.responses.build(poll_response_params.merge(user: current_user))

    if @response.save
      message = {notice: "Responded to poll."}
    else
      message = {alert: "Failed to respond to poll: #{@response.errors}"}
    end

    redirect_to event_path(@poll.event), message
  end

  def destroy
    current_user.poll_responses.find(params[:id]).destroy

    redirect_to event_path(@poll.event), notice: "Removed response to poll."
  end

  private

  def poll_response_params
    params.require(:poll_response).permit(:choice, :example_response)
  end

  def set_poll
    @poll = Poll.find(params[:poll_id])
  end
end
