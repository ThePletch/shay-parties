class AttendancesController < ApplicationController
  before_action :set_event
  before_action :set_attendance, only: [:update, :destroy]
  before_action :authenticate_user!

  # POST /attendances
  # POST /attendances.json
  def create
    @attendance = @event.attendances.build(invitable: current_user, rsvp_status: attendance_params[:rsvp_status])

    respond_to do |format|
      if @attendance.save
        format.html { redirect_to @event, notice: 'RSVP successful.' }
        format.json { render :show, status: :created, location: @attendance }
      else
        format.html { redirect_to @event, alert: @attendance.errors.values.flatten.join("\n") }
        format.json { render json: @attendance.errors, status: :unprocessable_entity }
      end
    end
  end

  # PATCH/PUT /attendances/1
  # PATCH/PUT /attendances/1.json
  def update
    respond_to do |format|
      if @attendance.update(attendance_params)
        format.html { redirect_to @event, notice: 'RSVP updated.' }
        format.json { render :show, status: :ok, location: @attendance }
      else
        format.html { redirect_to @event, alert: @attendance.errors.values.flatten.join("\n") }
        format.json { render json: @attendance.errors, status: :unprocessable_entity }
      end
    end
  end

  # DELETE /attendances/1
  # DELETE /attendances/1.json
  def destroy
    @attendance.destroy
    respond_to do |format|
      format.html { redirect_to @event, notice: 'RSVP deleted.' }
      format.json { head :no_content }
    end
  end

  private
    # Use callbacks to share common setup or constraints between actions.
    def set_attendance
      @attendance = Attendance.find(params[:id])
      unless @attendance.invitable_id == current_user.id
        redirect_back fallback_location: root_path, alert: "You can't edit other people's RSVPs."
      end
    end

    def set_event
      @event = Event.find(params[:event_id])
    end

    # Once an RSVP is created, you can't change its attendee or its event.
    def attendance_params
      params.require(:attendance).permit(:rsvp_status)
    end
end
