class AttendanceDecorator < Draper::Decorator
  decorates :attendance

  decorates_association :attendee

  delegate_all
end
