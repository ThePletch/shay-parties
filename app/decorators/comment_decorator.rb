class CommentDecorator < Draper::Decorator
  decorates :comment

  decorates_association :creator

  delegate_all

  def created_timestamp
    comment.created_at.strftime(comment_datetime_format)
  end

  def created_date
    created_at.strftime(comment_date_format)
  end

  def created_time
    created_at.strftime(comment_time_format)
  end

  def created_datetime
    created_at
  end

  def updated_timestamp
    comment.updated_at.strftime(comment_datetime_format)
  end

  def updated_date
    updated_at.strftime(comment_date_format)
  end

  def updated_time
    updated_at.strftime(comment_time_format)
  end

  def updated_datetime
    updated_at
  end

  def rendered_body
    ActionController::Base.helpers.sanitize markdown.render(comment.body || '')
  end

  private

  def comment_datetime_format
    [comment_date_format, comment_time_format].join(" ")
  end

  def comment_date_format
    "%b %-d, %Y"
  end

  def comment_time_format
    "%l:%M %P"
  end

  def markdown
    @markdown ||= Redcarpet::Markdown.new(Redcarpet::Render::HTML.new)
  end
end
