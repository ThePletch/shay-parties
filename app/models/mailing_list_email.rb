class MailingListEmail < ApplicationRecord
  belongs_to :mailing_list, inverse_of: :emails
  belongs_to :user, optional: true

  def match_to_user(force: false)
    if user.nil? || force
      self.update(user: User.find_by(email: self.email))
    end
  end

  def self.no_decline_rsvp_for_event(event)
    where(<<~SQL.squish, event.id)
      mailing_list_emails.user_id IS NULL OR NOT EXISTS (
        SELECT 1 FROM attendances
        WHERE attendances.attendee_id = mailing_list_emails.user_id
          AND attendances.attendee_type = 'User'
          AND attendances.event_id = ?
          AND attendances.rsvp_status = 'No'
      )
    SQL
  end

  def self.attending_event(event)
    joins(user: :attendances).where(attendances: {event_id: event.id, rsvp_status: ['Yes', 'Maybe']})
  end
end
