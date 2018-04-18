class EventDecorator < Draper::Decorator
  decorates :event

  delegate_all

  def start_time
    event.start_time.strftime(event_date_format)
  end

  def end_time
    event.end_time.strftime(event_date_format)
  end

  def description
    ActionController::Base.helpers.sanitize markdown.render(event.description)
  end

  private

  def event_date_format
    "%B %-d, %Y %l:%M %p"
  end

  def markdown
    @markdown ||= Redcarpet::Markdown.new(Redcarpet::Render::HTML.new)
  end
end
