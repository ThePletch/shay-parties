class EventsController < ApplicationController
  before_action :authenticate_user!, except: [:show, :index]
  before_action :set_event, only: [:show, :rsvp]
  before_action :set_owned_event, only: [:edit, :update, :destroy]
  before_action :require_creator!, except: [:show, :index, :rsvp]

  def index
    @current_scope = params[:scope] || "future"

    case @current_scope
    when "past"
      @events = Event.where("end_time < ?", Time.current)
    else
      @events = Event.where("end_time > ?", Time.current)
    end
  end

  def show
    if user_signed_in?
      @attendance = @event.attendances.find_by(invitable_id: current_user.id) || @event.attendances.build
    end

    @event = EventDecorator.decorate(@event)
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
    if @event.event_members.where(invitee_id: current_user.id).any?
      redirect_back fallback_location: root_path, alert: "You've already RSVPed!"
      return
    end

    @event.event_members.create(invitee: current_user)
  end

  private

  def set_event
    @event = Event.find(params[:id])
  end

  # ensures that the event being access is owned by the current user
  def set_owned_event
    @event = current_user.managed_events.find(params[:id])
  end

  def event_params
    params.require(:event).permit(:title, :start_time, :end_time, :description, address_attributes: [
      :street,
      :street2,
      :city,
      :state,
      :zip_code
    ])
  end

  def require_creator!
    unless current_user.creator?
      redirect_back fallback_location: root_path, alert: "You're not allowed to manage events yet."
    end
  end
end
