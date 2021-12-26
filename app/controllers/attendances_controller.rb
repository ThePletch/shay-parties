class AttendancesController < ApplicationController
  before_action :require_user_or_guest_auth, except: [:create]
  before_action :set_event, only: [:create]
  before_action :set_owned_attendance, only: [:update]
  before_action :set_attendance, only: [:destroy]
  before_action :require_own_attendance_or_event, only: [:destroy]

  # POST /attendances
  # POST /attendances.json
  def create
    attendee = @authenticated_user || Guest.new(attendee_params)
    @attendance = @event.attendances.build(attendee: attendee, rsvp_status: attendance_params[:rsvp_status])

    if @attendance.save
      if @attendance.attendee.guest?
        notice = t 'attendance.created'
      else
        notice = t 'attendance.created_with_link_html', link: event_url(@event, guest_guid: @attendance.attendee.guid)
      end

      redirect_to event_path(@event, guest_guid: @attendance.attendee.try(:guid)), notice: notice
    else
      redirect_to @event, alert: @attendance.errors.values.flatten.join("\n")
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
      result = @attendance.update(attendance_params)
    end

    if result
      if @attendance.persisted?
        redirect_to event_path(event, guest_guid: params[:guest_guid]), notice: t('attendance.updated')
      else
        redirect_to event_path(event), notice: t('attendance.destroyed')
      end
    else
      redirect_to event_path(event, guest_guid: params[:guest_guid]), alert: @attendance.errors.values.flatten.join("\n")
    end
  end

  private

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
    if not (@attendance.attendee == @authenticated_user or @attendance.event.owned_by?(current_user))
      redirect_to event_path(@attendance.event, guest_guid: params[:guest_guid]), alert: t('attendance.rejection.unauthorized_removal')
    end
  end

  def set_event
    @event = Event.friendly.find(params[:event_id])
  end

  # Once an RSVP is created, you can't change its attendee or its event.
  def attendance_params
    params.require(:attendance).permit(:rsvp_status)
  end

  def attendee_params
    params.require(:attendee).permit(:name, :email)
  end
end
