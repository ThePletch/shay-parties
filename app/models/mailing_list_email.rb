class MailingListEmail < ApplicationRecord
  belongs_to :mailing_list, inverse_of: :emails
  belongs_to :user

  def match_to_user(force: false)
    if user.nil? || force
      self.update(user: User.find_by(email: self.email))
    end
  end

  def self.no_decline_rsvp_for_event(event)
    left_joins(:user).where.not(
      Attendance.where("user_id = users.id and event_id = #{event.id} and rsvp_status = 'No'").exists
    )
  end

  def self.attending_event(event)
    joins(user: :attendances).where(attendances: {event_id: event.id, rsvp_status: ['Yes', 'Maybe']})
  end
end
