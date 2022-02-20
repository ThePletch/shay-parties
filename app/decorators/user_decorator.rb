class UserDecorator < CreatorDecorator
  decorates :user

  delegate_all
end
