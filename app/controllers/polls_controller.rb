class PollsController < ApplicationController
  before_action :set_event, except: [:edit, :update, :destroy]
  before_action :set_poll, except: [:new, :create]
  before_action :authenticate_user!

  def edit
  end

  def update
    if @poll.update(poll_params)
      redirect_to event_path(@poll.event), notice: 'Poll was successfully updated.'
    else
      render :edit
    end
  end

  def new
    @poll = Poll.new
  end

  def create
    @poll = @event.polls.build(poll_params.merge(owner: current_user))

    if @poll.save
      redirect_to event_path(@poll.event), notice: 'Poll was successfully created.'
    else
      render :new
    end
  end

  def destroy
    @poll.destroy

    redirect_to event_path(@poll.event), notice: 'Poll was deleted.'
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
