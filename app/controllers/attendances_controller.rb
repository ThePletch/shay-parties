class AttendancesController < ApplicationController
  before_action :require_user_or_guest_auth, except: [:create]
  before_action :set_event, only: [:create]
  before_action :set_owned_attendance, only: [:update]
  before_action :set_attendance, only: [:destroy]
  before_action :require_own_attendance_or_event, only: [:destroy]

  # POST /attendances
  def create
    attendee = @authenticated_user || Guest.new(attendance_params[:attendee_attributes])

    # RSVPing can overwrite an existing plus-one, but not someone else's direct RSVP.
    # chicanery is required to filter on a polymorphic association
    existing_plus_one_attendance = @event.attendances
                                         .includes(:guest)
                                         .where(
                                            guest: {email: attendee.email}
                                          )
                                         .where.not(attendance_id: nil)
                                         .take
    @attendance = existing_plus_one_attendance || @event.attendances.build(
      attendee: attendee,
      rsvp_status: attendance_params[:rsvp_status],
    )

    # in case this is an existing attendance, erase its plus-one status and update its name.
    @attendance.parent_attendance = nil
    @attendance.attendee.name = attendee.name

    if upsert(@attendance, @event)
      if @attendance.attendee.guest?
        notice = t 'attendance.created_with_link_html', link: event_url(@event, guest_guid: @attendance.attendee.guid)
      else
        notice = t 'attendance.created'
      end

      redirect_to event_path(@event, guest_guid: @attendance.attendee.try(:guid)), notice: notice
    else
      render 'events/show', alert: t('activerecord.errors.models.attendance.rejection') + ": " + @attendance.errors.map{|e| e.full_message }.join(". "), status: :unprocessable_entity
    end
  end

  def destroy
    if @attendance.destroy
      redirect_to event_path(@attendance.event), {notice: t('attendance.destroyed')}
    else
      redirect_to event_path(@attendance.event, guest_guid: params[:guest_guid]), {alert: t('destroyed_failed')}
    end
  end


  def update
    event = @attendance.event

    if attendance_params[:rsvp_status] == "No RSVP"
      result = @attendance.destroy
    else
      result = upsert(@attendance, event)
    end

    if result
      if @attendance.persisted?
        redirect_to event_path(event, guest_guid: @attendance.attendee.try(:guid)), notice: t('attendance.updated')
      else
        redirect_to event_path(event), notice: t('attendance.destroyed')
      end
    else
      redirect_to event_path(event, guest_guid: params[:guest_guid]), alert: @attendance.errors.values.flatten.join("\n")
    end
  end

  private

  def upsert(attendance, event)
    attendance.update(attendance_params_for_upsert(attendance_params, event))
  end

  def attendance_params_for_upsert(params, event)
    {
      **params,
      'event_id' => event.id,
      'plus_ones_attributes' => (attendance_params['plus_ones_attributes'] || {}).transform_values do |plus_one|
        {
          **plus_one,
          'attendee_type' => 'Guest',
          'event_id' => event.id,
          'rsvp_status' => params['rsvp_status'],
        }
      end,
    }
  end

  def require_user_or_guest_auth
    unless @authenticated_user
      redirect_to new_user_session_path, alert: t('attendance.rejection.unauthenticated')
      return
    end
  end

  def set_owned_attendance
    @attendance = @authenticated_user.attendances.find(params[:id])
  end

  def set_attendance
    @attendance = Attendance.find(params[:id])
  end

  def require_own_attendance_or_event
    permissible_states = [
      # this is your attendance
      Proc.new{ @attendance.attendee == @authenticated_user },
      # this is your plus-one
      Proc.new{ @attendance.parent_attendance.try(:attendee) == @authenticated_user },
      # you own this event
      Proc.new{ @attendance.event.owned_by?(current_user) },
    ]

    if permissible_states.lazy.none?{|state| state.call }
      redirect_to event_path(@attendance.event, guest_guid: params[:guest_guid]), alert: t('attendance.rejection.unauthorized_removal')
    end
  end

  def set_event
    @event = EventDecorator.decorate(Event.friendly.find(params[:event_id]))
  end

  # Once an RSVP is created, you can't change its attendee or its event.
  def attendance_params
    params.require(:attendance).permit(
      :rsvp_status,
      attendee_attributes: [
        :id,
        :name,
        :email,
      ],
      plus_ones_attributes: [
        :_destroy,
        :id,
        :event_id,
        {attendee_attributes: [:id, :name, :email]},
      ])
  end
end
