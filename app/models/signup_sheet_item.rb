class SignupSheetItem < ApplicationRecord
  belongs_to :event
  belongs_to :attendee, polymorphic: true, optional: true

  validates :event, presence: true
  validates :attendee, presence: true, if: -> { !requested }
  validate :attendee_is_attending_event

  scope :requested, -> { where(requested: true) }
  scope :unclaimed, -> { where(attendee: nil) }

  def claimed?
    attendee.present?
  end

  def claimed_by?(claimant)
    attendee.id == claimant.id
  end

  # additional permissions logic not enforced by state validations
  def attendee_can?(action, actor)
    case action
    when 'edit'
      if self.requested
        event.owned_by?(actor)
      else
        self.claimed_by?(actor)
      end
    when 'delete'
      event.owned_by?(actor) or !self.requested and self.claimed_by?(actor)
    when 'unclaim'
      self.requested and self.claimed_by?(actor)
    when 'claim'
      !self.claimed?
    else
      throw RuntimeError.new("unknown action #{action}")
    end
  end

  class << self
    def attendee_can_create_for_event?(target_event, actor)
      target_event.owned_by?(actor) or target_event.signup_context.guest_enterable?
    end
  end

  private

  def attendee_is_attending_event
    if attendee and not attendee.attending?(event, 'Yes')
      errors.add(:attendee, :not_attending_event)
    end
  end
end
