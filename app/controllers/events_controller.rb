class EventsController < ApplicationController
  before_action :authenticate_user!, except: [:show, :index]
  before_action :set_event, only: [:show, :rsvp]
  before_action :set_owned_event, only: [:edit, :update, :destroy]
  before_action :load_prior_addresses, only: [:new, :edit, :create, :update]

  def index
    # nothing to look up if there aren't any users, so we short circuit.
    return if User.none?

    if params[:user_id]
      @target_user = User.find(params[:user_id])
    else
      @target_user = User.default_host
    end

    @current_scope = params[:scope] || "future"

    @events = @target_user.managed_events

    case @current_scope
    when "past"
      @events = @events.where("end_time < ?", Time.current)
    else
      @events = @events.where("end_time > ?", Time.current)
    end
  end

  def show
    if user_signed_in?
      @attendance = @event.attendances.find_by(user_id: current_user.id) || @event.attendances.build
    end

    @event = EventDecorator.decorate(@event)
    commontator_thread_show(@event)
  end

  def new
    @event = Event.new
    @event.build_address if @event.address.nil?
  end

  def edit
    @event.build_address if @event.address.nil?
  end

  def create
    @event = current_user.managed_events.build(event_params)

    if @event.save
      redirect_to @event, notice: 'Event was successfully created.'
    else
      render :new
    end
  end

  def update
    if @event.update(event_params)
      redirect_to @event, notice: 'Event was successfully updated.'
    else
      render :edit
    end
  end

  def destroy
    @event.destroy
    redirect_to events_url, notice: 'Event was successfully destroyed.'
  end

  def rsvp
    if @event.attendees.find_by(user_id: current_user.id).exists?
      redirect_back fallback_location: root_path, alert: "You've already RSVPed!"
      return
    end

    @event.attendances.create(user: current_user)
  end

  private

  def set_event
    @event = Event.find(params[:id])
  end

  # ensures that the event being access is owned by the current user
  def set_owned_event
    @event = current_user.managed_events.find(params[:id])
  end

  def load_prior_addresses
    @prior_addresses = current_user.addresses
  end

  def event_params
    params.require(:event).permit(:title, :start_time, :end_time, :description, :photo, :address_id, address_attributes: [
      :street,
      :street2,
      :city,
      :state,
      :zip_code
    ])
  end
end
