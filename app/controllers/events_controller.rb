class EventsController < ApplicationController
  before_action :authenticate_user!, except: [:show, :ical, :index]
  before_action :set_event, only: [:show, :ical]
  before_action :set_owned_event, only: [:edit, :update, :destroy]
  before_action :load_prior_addresses, only: [:new, :edit, :create, :update]

  PRELOAD = [:owner, {attendances: :attendee, commontator_thread: :comments, polls: :responses}]

  def index
    if params[:user_id]
      @target_user = User.friendly.find(params[:user_id])

      # users can see their own secret events
      if current_user and current_user == @target_user
        @events = @target_user.managed_events
      else
        if current_user
          @events = @target_user.managed_events.left_joins(:attendances).where("NOT events.secret OR (attendances.attendee_id = ? and attendances.attendee_type = 'User')", current_user.id).distinct
        else
          @events = @target_user.managed_events.not_secret
        end
      end
    else
      if current_user
        @events = Event.left_joins(:attendances).where("NOT events.secret OR (attendances.attendee_id = ? and attendances.attendee_type = 'User')", current_user.id).distinct
      else
        @events = Event.not_secret
      end
    end

    @current_scope = params[:scope] || "future"

    case @current_scope
    when "past"
      @events = @events.where("end_time < ?", Time.current)
    else
      @events = @events.where("end_time > ?", Time.current)
    end



    @events = @events.order(end_time: :desc)
  end

  def show
    if user_signed_in?
      @attendee = current_user
      @attendance = @event.attendances.find_by(attendee: current_user) || @event.attendances.build
    elsif params[:guest_guid] and guest = Guest.find_by(guid: params[:guest_guid])
      @attendee = guest
      @attendance = @event.attendances.find_by(attendee: guest) || @event.attendances.build
    else
      @attendance = @event.attendances.build
    end

    # load page with comments displayed
    commontator_thread_show(@event)
  end

  # get an ical event version of this event
  def ical
    send_data @event.icalendar(event_url(@event)).to_ical, type: 'text/calendar', filename: "#{@event.title}.ics"
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
      redirect_to @event, notice: t('event.created')
    else
      render :new
    end
  end

  def update
    if @event.update(event_params)
      redirect_to @event, notice: t('event.updated')
    else
      render :edit
    end
  end

  def destroy
    @event.destroy
    redirect_to events_url, notice: t('event.destroyed')
  end

  private

  def set_event
    @event = EventDecorator.decorate(Event.includes(*EventsController::PRELOAD).friendly.find(params[:id]))
  end

  # ensures that the event being access is owned by the current user
  def set_owned_event
    @event = current_user.managed_events.includes(*EventsController::PRELOAD).friendly.find(params[:id])
  end

  def load_prior_addresses
    @prior_addresses = current_user.addresses
  end

  def event_params
    params.require(:event).permit(:title, :secret, :start_time, :end_time, :description, :photo, :address_id, address_attributes: [
      :street,
      :street2,
      :city,
      :state,
      :zip_code
    ])
  end
end
