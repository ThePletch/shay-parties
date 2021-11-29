module I18nHelper
  def attendance_types_localized
    localized_attendances = t("attendance.status")

    (["No RSVP"] + Attendance::RSVP_TYPES).map do |rsvp|
      [localized_attendances[rsvp.to_sym], rsvp]
    end
  end
end
