# We terminate SSL at the CDN level, which means that Rails is not aware that it's running behind SSL.
# To avoid this causing Problems, we need to explicitly tell Rails to use HTTPS anywhere where we're
# forced to use a full URL rather than a path (such as with direct uploads to ActiveStorage).
# There's no way to do this via config for specific URLs unless you configured the route yourself,
# and the URL helper for this feature is both created and called via an internal package with no relevant config exposed,
# meaning that we are forced to monkey-patch the route's properties after routing is loaded (post-action-controller)
ActiveSupport.on_load(:action_controller) do
  if Rails.application.config.force_https_in_direct_uploads_url
    Rails.application.routes.named_routes.get(:rails_direct_uploads).defaults[:protocol] = 'https'
  end
end
