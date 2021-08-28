module GcalHelper
    def gcal_url(event)
        AddToCalendar::URLs.new(
          start_datetime: event.start_datetime,
          end_datetime: event.end_datetime,
          title: event.title,
          timezone: ActiveSupport::TimeZone::MAPPING[Time.zone.name],
          location: event.address.to_s.gsub("\n", " "),
          url: event_url(event),
          description: event.description.gsub(/\n+/, "\n")
        ).google_url
    end
end
