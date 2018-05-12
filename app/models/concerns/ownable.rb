# autogenerates a presenter of the appropriate type
module Ownable
  extend ActiveSupport::Concern

  included do
    belongs_to :owner, class_name: "User", foreign_key: :user_id
  end

  def owned_by?(user)
    user && user.id == owner.id
  end
end
