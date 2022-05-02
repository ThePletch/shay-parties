module Api
  class EventsController < ApiController
    def index
      events = get_events_list

      current_scope = params[:scope] || "past"

      case current_scope
      when "past"
        events = events.where("end_time < ?", Time.current)
      else
        events = events.where("end_time > ?", Time.current)
      end

      events = events.order(end_time: :desc)

      render json: events
    end

    private

    def get_events_list
      events = Event.all.includes(:attendances, :owner)

      user_scoped_events_list(events, current_api_user)
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
  end
end
