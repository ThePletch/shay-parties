class ApplicationController < ActionController::Base
  protect_from_forgery with: :exception

  before_action :permit_additional_user_params, if: :devise_controller?

  private

  def permit_additional_user_params
    devise_parameter_sanitizer.permit(:account_update, keys: [:name])
  end
end
