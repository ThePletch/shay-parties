class Users::RegistrationsController < Devise::RegistrationsController
  before_action :verify_turnstile, only: [:create]

  protected

  def build_resource(hash = {})
    super(hash)
    self.resource.strict_loading!(false)
  end

  # Unconfirmed users already see the persistent confirmation banner;
  # skip Devise's "Welcome! You have signed up" notice to avoid two flashes.
  def after_sign_up_path_for(resource)
    flash.delete(:notice) unless resource.confirmed?
    super
  end

  private

  def verify_turnstile
    token = params["cf-turnstile-response"]
    return if Cloudflare::Turnstile.verify(token, remote_ip: request.remote_ip)

    build_resource(sign_up_params)
    resource.validate
    resource.errors.add(:base, t("turnstile.failed"))
    clean_up_passwords resource
    set_minimum_password_length
    render :new, status: :unprocessable_content
  end
end
