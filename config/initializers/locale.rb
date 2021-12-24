# allow for nested i18n files
I18n.load_path += Dir[Rails.root.join('config', 'locales', '**', '*.{rb,yml}')]
I18n.available_locales = [:en, :es]
I18n.default_locale = :en
