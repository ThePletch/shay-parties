class AttendancesController < ApplicationController
  before_action :set_event, only: [:create]
  before_action :set_attendance, only: [:update, :destroy]
  before_action :authenticate_user!

  # POST /attendances
  # POST /attendances.json
  def create
    @attendance = @event.attendances.build(user: current_user, rsvp_status: attendance_params[:rsvp_status])

    if @attendance.save
      redirect_to @event, notice: 'RSVP successful.'
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
      redirect_to event, notice: 'RSVP updated.'
    else
      redirect_to event, alert: @attendance.errors.values.flatten.join("\n")
    end
  end

  private

  def set_attendance
    @attendance = current_user.attendances.find(params[:id])
  end

  def set_event
    @event = Event.find(params[:event_id])
  end

  # Once an RSVP is created, you can't change its attendee or its event.
  def attendance_params
    params.require(:attendance).permit(:rsvp_status)
  end
end
