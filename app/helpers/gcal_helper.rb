module GcalHelper
    def gcal_url(event)
        AddToCalendar::URLs.new(
          start_datetime: event.start_time,
          end_datetime: event.end_time,
          title: event.title,
          timezone: ActiveSupport::TimeZone::MAPPING[Time.zone.name],
          location: event.address.to_s.gsub("\n", " "),
          url: event_url(event),
          description: event.description.to_s.gsub(/\n+/, "\n")
        ).google_url
    end
end
