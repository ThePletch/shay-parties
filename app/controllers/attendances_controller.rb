class AttendancesController < ApplicationController
  include GuestUrls

  before_action :set_event, only: [:create]
  before_action :set_attendance, only: [:update, :destroy]

  # POST /attendances
  # POST /attendances.json
  def create
    if current_user
      @attendance = @event.attendances.build(attendee: current_user, rsvp_status: attendance_params[:rsvp_status])
    else
      guest = Guest.new(attendee_params)
      @attendance = @event.attendances.build(attendee: guest, rsvp_status: attendance_params[:rsvp_status])
    end

    if @attendance.save
      if current_user
        notice = 'RSVP successful.'
      else
        notice = "RSVP successful. You can manage your RSVP at #{event_url(@event, guest_guid: @attendance.attendee.guid)}"
      end

      redirect_to event_url(@event, guest_guid: @attendance.attendee.try(:guid)), notice: notice
    else
      redirect_to @event, alert: @attendance.errors.values.flatten.join("\n")
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
        redirect_to event_url_with_guid(event), notice: 'RSVP updated.'
      else
        redirect_to event_path(event), notice: 'RSVP removed.'
      end
    else
      redirect_to event_url_with_guid(event), alert: @attendance.errors.values.flatten.join("\n")
    end
  end

  private

  def set_attendance
    if current_user
      @attendance = current_user.attendances.find(params[:id])
    elsif params[:guest_guid].nil?
      redirect_to new_user_session_path
    else
      if guest = Guest.find_by(guid: params[:guest_guid])
        @attendance = guest.attendances.find(params[:id])
      else
        redirect_to new_user_session_path, notice: "Unrecognized guest ID."
      end
    end
  end

  def set_event
    @event = Event.find(params[:event_id])
  end

  # Once an RSVP is created, you can't change its attendee or its event.
  def attendance_params
    params.require(:attendance).permit(:rsvp_status)
  end

  def attendee_params
    params.require(:attendee).permit(:name, :email)
  end
end
