class EventDecorator < Draper::Decorator
  decorates :event

  decorates_association :comments

  delegate_all

  def start_timestamp
    event.start_time.strftime(event_datetime_format)
  end

  def start_date
    event.start_time.strftime(event_date_format)
  end

  def start_time
    event.start_time.strftime(event_time_format)
  end

  def start_datetime
    event.start_time
  end

  def end_timestamp
    event.end_time.strftime(event_datetime_format)
  end

  def end_date
    event.end_time.strftime(event_date_format)
  end

  def end_time
    event.end_time.strftime(event_time_format)
  end

  def end_datetime
    event.end_time
  end

  def description
    ActionController::Base.helpers.sanitize Commonmarker.to_html(event.description || '')
  end

  def attended_by?(user)
    if user and attendance = event.attendances.find_by(attendances: {attendee: user})
      attendance.attending?
    else
      false
    end
  end

  def root_comments
    comments.select{|c| c.parent_id.nil? }
  end

  private

  def event_datetime_format
    [event_date_format, event_time_format].join(" ")
  end

  def event_date_format
    "%b %-d, %Y"
  end

  def event_time_format
    "%l:%M %P"
  end
end
