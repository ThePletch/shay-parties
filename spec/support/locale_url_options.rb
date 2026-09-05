# frozen_string_literal: true

RSpec.configure do |config|
  config.before(:each, type: :view) do
    def controller.default_url_options
      {locale: I18n.locale}
    end
  end
end
