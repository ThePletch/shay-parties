module EventTime
  class << self
    def same_day_range(event)
      "#{I18n.l(event.start_time, format: :clock)} - #{I18n.l(event.end_time, format: :clock)}"
    end
  end
end
