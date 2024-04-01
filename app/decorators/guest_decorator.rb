class GuestDecorator < AttendeeDecorator
  decorates :guest

  delegate_all
end
