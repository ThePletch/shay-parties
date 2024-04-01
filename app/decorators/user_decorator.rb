class UserDecorator < AttendeeDecorator
  decorates :user

  delegate_all
end
