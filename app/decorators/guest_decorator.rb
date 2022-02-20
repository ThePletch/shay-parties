class GuestDecorator < CreatorDecorator
  decorates :guest

  delegate_all
end
