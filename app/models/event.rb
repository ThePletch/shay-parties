class Event < ApplicationRecord
  acts_as_attendable :event_attendances, by: :users
end
