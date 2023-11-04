ActiveSupport.on_load(:action_controller) do
  ActionController::Base.prepend(CoreExtensions::UrlOptionsOverride)
  ActionDispatch::Routing::UrlFor.prepend(CoreExtensions::UrlOptionsOverride)
end
