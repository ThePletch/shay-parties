Rails.application.config.middleware.insert_before 0, Rack::Cors do
  allow do
    origins '*'
    resource '/api/*',
      headers: %w(Authorization),
      expose: %w(Authorization),
      methods: :any
  end
end
