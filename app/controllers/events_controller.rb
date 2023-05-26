class EventsController < ApplicationController
  before_action :authenticate_user!, except: [:show, :ical, :index, :attendee_index]
  before_action :set_event, only: [:show, :ical]
  before_action :set_owned_event, only: [:edit, :update, :destroy]
  before_action :load_prior_addresses, only: [:new, :edit, :create, :update]

  PRELOAD = [
    :address,
    :owner,
    {
      attendances: :attendee,
      comments: [:creator, :editor],
      polls: :responses,
    },
  ]

  def index
    if params[:user_id]
      @host = User.friendly.find(params[:user_id])
      if current_user && current_user == @host
        @index_title = t('event.index.self')
      else
        @index_title = t('event.index.for_user', name: @host.name)
      end
    else
      @index_title = t('event.index.public')
    end

    @events, @current_scope = time_scoped_events_list(get_events_list_for(@host), params[:scope])
  end

  def attendee_index
    if @authenticated_user.nil?
      redirect_to events_url, notice: t('event.index.attending.auth_required')
      return
    end

    @index_title = t('event.index.attending.title')

    @events, @current_scope = time_scoped_events_list(@authenticated_user.rsvped_events, params[:scope])

    render :index
  end

  def show
    if @authenticated_user
      @attendee = @authenticated_user
      @attendance = @event.attendances.includes(:attendee, plus_ones: :attendee).find_by(attendee: @authenticated_user)
    end

    @attendance ||= @event.attendances.includes(:attendee).build
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

  def get_events_list_for(host)
    if host
      events = host.managed_events

      # users can see all their own events, so we short-circuit here for users
      # viewing their own events list to avoid any further filtering
      if @authenticated_user == host
        return events.includes(:attendances, :owner)
      end
    else
      events = Event.all
    end

    events = events.includes(:attendances, :owner)

    user_scoped_events_list(events, @authenticated_user)
  end

  def time_scoped_events_list(events, target_scope)
    case target_scope
    when "past"
      return [events.where("end_time <= ?", Time.current).order(end_time: :desc), "past"]
    else
      return [events.where("end_time > ?", Time.current).order(end_time: :desc), "future"]
    end
  end

  # Hides all secret events except ones the user has already RSVPed to.
  # Obviously, unauthenticated users haven't RSVPed to any events.
  def user_scoped_events_list(events, viewing_user)
    if viewing_user
      events.left_joins(:attendances).where("NOT events.secret OR (attendances.attendee_id = ? and attendances.attendee_type = 'User')", viewing_user.id).distinct
    else
      events.not_secret
    end
  end

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
