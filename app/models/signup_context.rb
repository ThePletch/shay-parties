class SignupContext < ApplicationRecord
  belongs_to :event

  def guest_enterable?
    guest_enterable
  end
end
