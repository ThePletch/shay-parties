class Users::RegistrationsController < Devise::RegistrationsController
  protected

  def build_resource(hash = {})
    super(hash)
    self.resource.strict_loading!(false)
  end
end
