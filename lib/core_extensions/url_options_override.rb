# require 'action_controller/base'
# farting noise
module CoreExtensions
  module UrlOptionsOverride
    def default_url_options
      options = { locale: I18n.locale }
      options[:protocol] = 'https' if Rails.application.config.force_https_in_route_helpers

      options
    end
  end
end
