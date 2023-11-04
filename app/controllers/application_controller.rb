class ApplicationController < ActionController::Base
  include AuthHelper

  protect_from_forgery with: :exception

  before_action :permit_additional_user_params, if: :devise_controller?
  before_action :set_locale, :set_authenticated_user
  before_action :store_user_location!, if: :storable_location?

  def after_sign_in_path_for(resource_or_scope)
    stored_location_for(resource_or_scope) || super
  end

  private

  def storable_location?
    request.get? && is_navigational_format? && !devise_controller? && !request.xhr?
  end

  def store_user_location!
    # :user is the scope we are authenticating
    store_location_for(:user, request.fullpath)
  end

  def set_locale
    if params[:locale]
      if I18n.available_locales.include?(params[:locale].to_sym)
        I18n.locale =  params[:locale]
      else
        raise I18n::InvalidLocale.new(params[:locale])
      end
    else
      I18n.locale = I18n.default_locale
    end
  end

  def set_authenticated_user
    @authenticated_user = user_or_guest
  end

  def permit_additional_user_params
    devise_parameter_sanitizer.permit(:account_update, keys: [:name])
    devise_parameter_sanitizer.permit(:sign_up, keys: [:name])
  end
end
