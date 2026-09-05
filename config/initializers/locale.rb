# allow for nested i18n files
I18n.load_path += Dir[Rails.root.join('config', 'locales', '**', '*.{rb,yml}')]
I18n.available_locales = [:en, :es]
I18n.default_locale = :en

module RouteSetLocaleDefault
  def default_url_options
    (super || {}).merge(locale: I18n.locale)
  end
end

Rails.application.config.after_initialize do
  Rails.application.routes.singleton_class.prepend(RouteSetLocaleDefault)
end
