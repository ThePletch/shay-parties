class UsersController < ApplicationController
  before_action :require_creator!

  def index
  end

  def update
  end

  private

  def poll_params
    params.require(:poll).permit(:question, responses_attributes: [:_destroy, :id, :example_response, :choice])
  end

  def set_event
    @event = current_user.managed_events.find(params[:event_id])
  end

  def set_poll
    @poll = current_user.polls.find(params[:id])
  end
end
