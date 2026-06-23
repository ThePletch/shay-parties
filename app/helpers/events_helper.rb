module EventsHelper
  def event_header_image_tag(event)
    if event.photo.attached?
      if event.landing_page_photo_ready?
        image_tag url_for(event.landing_page_photo), class: "hero-photo"
      else
        image_tag rails_storage_redirect_path(event.photo),
          class: "hero-photo hero-photo--pending",
          data: { crop_y_offset: event.photo_crop_y_offset }
      end
    else
      image_tag vite_asset_path("images/default_event_image.jpg"), class: "hero-photo"
    end
  end

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
    elsif attendance.event.owned_by?(attendance.attendee)
      'list-group-item-primary'
    else
      ''
    end
  end
end
