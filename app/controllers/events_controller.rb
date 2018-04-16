class EventsController < ApplicationController
  before_action :set_event, only: [:show, :edit, :update, :destroy, :rsvp]
  before_action :require_ownership!, only: [:edit, :update, :destroy]
  before_action :authenticate_user!, only: [:new, :create]

  # GET /events
  # GET /events.json
  def index
    @events = Event.all
  end

  # GET /events/1
  # GET /events/1.json
  def show
    if user_signed_in?
      @attendance = @event.attendances.find_by(invitable_id: current_user.id) || @event.attendances.build
    end
  end

  # GET /events/new
  def new
    @event = Event.new
  end

  # GET /events/1/edit
  def edit
  end

  # POST /events
  # POST /events.json
  def create
    @event = current_user.events.build(event_params)

    respond_to do |format|
      if @event.save
        format.html { redirect_to @event, notice: 'Event was successfully created.' }
        format.json { render :show, status: :created, location: @event }
      else
        format.html { render :new }
        format.json { render json: @event.errors, status: :unprocessable_entity }
      end
    end
  end

  # PATCH/PUT /events/1
  # PATCH/PUT /events/1.json
  def update
    respond_to do |format|
      if @event.update(event_params)
        format.html { redirect_to @event, notice: 'Event was successfully updated.' }
        format.json { render :show, status: :ok, location: @event }
      else
        format.html { render :edit }
        format.json { render json: @event.errors, status: :unprocessable_entity }
      end
    end
  end

  # DELETE /events/1
  # DELETE /events/1.json
  def destroy
    @event.destroy
    respond_to do |format|
      format.html { redirect_to events_url, notice: 'Event was successfully destroyed.' }
      format.json { head :no_content }
    end
  end

  def rsvp
    if @event.event_members.where(invitee_id: current_user.id).any?
      redirect_back fallback_location: root_path, alert: "You've already RSVPed!"
      return
    end

    @event.event_members.create(invitee: current_user)
  end

  private
    # Use callbacks to share common setup or constraints between actions.
    def set_event
      @event = Event.find(params[:id])
    end

    # Never trust parameters from the scary internet, only allow the white list through.
    def event_params
      params.require(:event).permit(:title, :start_time, :end_time, :description)
    end

    def require_ownership!
      authenticate_user!

      unless @event.user_id == current_user.id
        redirect_back fallback_location: root_path, alert: "You can't make changes to that event."
      end
    end
end
