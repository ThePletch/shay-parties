class EventDecorator < Draper::Decorator
  decorates :event

  delegate_all

  def start_time
    event.start_time.strftime(event_date_format)
  end

  def start_datetime
    event.start_time
  end

  def start_date
    event.start_time.strftime("%B %-d, %Y")
  end

  def end_time
    event.end_time.strftime(event_date_format)
  end

  def end_datetime
    event.end_time
  end

  def description
    ActionController::Base.helpers.sanitize markdown.render(event.description || '')
  end

  def attended_by?(user)
    if user and attendance = event.attendances.find_by(attendances: {attendee: user})
      attendance.attending?
    else
      false
    end
  end

  private

  def event_date_format
    "%B %-d, %Y %l:%M %p"
  end

  def markdown
    @markdown ||= Redcarpet::Markdown.new(Redcarpet::Render::HTML.new)
  end
end
