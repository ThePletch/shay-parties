class EventsController < ApplicationController
  before_action :authenticate_user!, except: [:show, :ical]
  before_action :set_event, only: [:show, :ical]
  before_action :set_owned_event, only: [:edit, :update, :destroy]
  before_action :load_prior_addresses, only: [:new, :edit, :create, :update]

  PRELOAD = [
    :address,
    :owner,
    {
      attendances: :attendee,
      comments: [:creator, :editor],
      photo_attachment: :blob,
      polls: :responses,
    },
  ]

  def host_index
    @hosted_list = true
    @index_title = t('event.index.self')
    @events, @current_scope = time_scoped_events_list(
      current_user.managed_events.includes(:attendances, :owner),
      params[:scope]
    )

    render :index
  end

  def attendee_index
    @index_title = t('event.index.attending.title')

    @events, @current_scope = time_scoped_events_list(current_user.rsvped_events, params[:scope])

    render :index
  end

  def show
    if @authenticated_user
      @attendee = @authenticated_user
      @attendance ||= @event.attendances.includes(:attendee, plus_ones: :attendee).find_by(attendee: @authenticated_user)
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
    redirect_to hosted_events_url, notice: t('event.destroyed')
  end

  private

  def time_scoped_events_list(events, target_scope)
    case target_scope
    when "past"
      return [events.where("end_time <= ?", Time.current).order(end_time: :desc), "past"]
    else
      return [events.where("end_time > ?", Time.current).order(end_time: :desc), "future"]
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
    params.require(:event).permit(
      :title,
      :start_time,
      :end_time,
      :requires_testing,
      :description,
      :photo,
      :photo_crop_y_offset,
      :plus_one_max,
      :address_id,
      address_attributes: [
        :street,
        :street2,
        :city,
        :state,
        :zip_code
      ],
      polls_attributes: [
        :id,
        :_destroy,
        :question,
        {
          responses_attributes: [
            [:_destroy, :id, :example_response, :choice]
          ]
        }
      ]
    )
  end
end
