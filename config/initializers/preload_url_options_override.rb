ActiveSupport.on_load(:action_controller) do
  if Rails.application.config.force_https_in_direct_uploads_url
    Rails.application.routes.named_routes.get(:rails_direct_uploads).defaults[:protocol] = 'https'
  end
end
