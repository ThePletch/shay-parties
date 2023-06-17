module EventsHelper
  def rsvps_order(attendances)
    attendances.includes(:attendee, parent_attendance: :attendee).sort_by do |attendance|
      [
        (attendance.parent_attendance.try(:attendee).try(:name) || attendance.attendee.name).downcase,
        attendance.attendance_id.present? ? '1' : '0',
        attendance.attendee.try(:name).try(:downcase),
      ]
    end
  end

  def rsvp_color_class(attendance)
    if attendance.attendance_id.present?
      'ms-5 list-group-item-info'
    elsif attendance.event.hosted_by?(attendance.attendee)
      'list-group-item-primary'
    else
      ''
    end
  end
end
