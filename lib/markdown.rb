module Markdown
  class << self
    def html(text)
      ActionController::Base.helpers.sanitize(Commonmarker.to_html(text || ""))
    end
  end
end
