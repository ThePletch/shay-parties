class ApplicationController < ActionController::Base
  protect_from_forgery with: :exception

  before_action :permit_additional_user_params, if: :devise_controller?
  before_action :set_locale

  private

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

  def permit_additional_user_params
    devise_parameter_sanitizer.permit(:account_update, keys: [:name])
    devise_parameter_sanitizer.permit(:sign_up, keys: [:name])
  end
end
