module GuestUrls
    extend ActiveSupport::Concern

    def event_url_with_guid(event)
        event_url(event, guest_guid: params[:guest_guid])
    end
end
