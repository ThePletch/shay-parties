# frozen_string_literal: true

class User < ApplicationRecord
  extend FriendlyId

  ROLES = %w[user admin superadmin suspended banned].freeze
  ADMIN_ROLES = %w[admin superadmin].freeze

  class ModerationError < StandardError; end

  # Include default devise modules. Others available are:
  # :lockable, :timeoutable and :omniauthable
  devise :database_authenticatable, :registerable,
         :recoverable, :rememberable, :trackable, :validatable,
         :confirmable

  friendly_id :name, use: :history

  # events the user owns
  has_many :managed_events, class_name: "Event", dependent: :destroy
  has_many :addresses, -> { distinct }, through: :managed_events
  # events the user has rsvped to - some of these may be 'no' rsvps,
  # hence not calling this 'attended_events'
  has_many :attendances, as: :attendee, dependent: :destroy
  has_many :rsvped_events, source: :event, through: :attendances, class_name: "Event"
  has_many :comments, as: :creator, dependent: :destroy
  has_many :edited_comments, as: :editor, class_name: "Comment"
  has_many :poll_responses, as: :respondent, dependent: :destroy
  has_many :polls, through: :managed_events
  has_many :answered_polls, through: :poll_responses
  has_many :mailing_lists, dependent: :destroy

  validate :email_not_denylisted, if: :email_changed?
  validate :unconfirmed_email_not_denylisted, if: :will_save_change_to_unconfirmed_email?

  def guest?
    false
  end

  def admin?
    role.in?(ADMIN_ROLES)
  end

  def superadmin?
    role == "superadmin"
  end

  def suspended?
    role == "suspended"
  end

  def banned?
    role == "banned"
  end

  def active_for_authentication?
    super && !suspended? && !banned?
  end

  def inactive_message
    if banned?
      :banned
    elsif suspended?
      :suspended
    else
      super
    end
  end

  def suspend!(actor:)
    ensure_can_moderate_account!(actor)
    update!(role: "suspended")
  end

  def unsuspend!(actor:)
    ensure_actor_is_admin!(actor)
    raise ModerationError, I18n.t("admin.users.errors.not_suspended") unless suspended?

    update!(role: "user")
  end

  def ban!(actor:, reason: nil)
    ensure_can_moderate_account!(actor)
    transaction do
      update!(role: "banned")
      emails_to_ban.each do |address|
        BannedEmail.ban!(address, banned_by: actor, reason: reason)
      end
    end
  end

  def unban!(actor:)
    ensure_actor_is_admin!(actor)
    raise ModerationError, I18n.t("admin.users.errors.not_banned") unless banned?

    transaction do
      BannedEmail.where(email: emails_to_ban.map { |e| BannedEmail.normalize(e) }).destroy_all
      update!(role: "user")
    end
  end

  def promote_to_admin!(actor:)
    ensure_actor_is_admin!(actor)
    raise ModerationError, I18n.t("admin.users.errors.cannot_moderate_self") if actor == self
    raise ModerationError, I18n.t("admin.users.errors.not_promotable") unless role == "user"
    ensure_email_confirmed!

    update!(role: "admin")
  end

  def demote_from_admin!(actor:)
    ensure_actor_is_admin!(actor)
    raise ModerationError, I18n.t("admin.users.errors.cannot_moderate_self") if actor == self
    raise ModerationError, I18n.t("admin.users.errors.cannot_demote_superadmin") if superadmin?
    raise ModerationError, I18n.t("admin.users.errors.not_demotable") unless role == "admin"

    update!(role: "user")
  end

  def make_superadmin!
    ensure_email_confirmed!
    update!(role: "superadmin")
  end

  private

  def should_generate_new_friendly_id?
    name_changed? || super
  end

  def emails_to_ban
    [email, unconfirmed_email].compact_blank
  end

  def email_not_denylisted
    return if email.blank?
    return unless BannedEmail.banned?(email)

    errors.add(:email, :banned)
  end

  def unconfirmed_email_not_denylisted
    return if unconfirmed_email.blank?
    return unless BannedEmail.banned?(unconfirmed_email)

    errors.add(:unconfirmed_email, :banned)
  end

  def ensure_email_confirmed!
    raise ModerationError, I18n.t("admin.users.errors.unconfirmed_email") unless confirmed?
  end

  def ensure_actor_is_admin!(actor)
    raise ModerationError, I18n.t("admin.users.errors.actor_not_admin") unless actor&.admin?
  end

  def ensure_can_moderate_account!(actor)
    ensure_actor_is_admin!(actor)
    raise ModerationError, I18n.t("admin.users.errors.cannot_moderate_self") if actor == self
    raise ModerationError, I18n.t("admin.users.errors.cannot_moderate_superadmin") if superadmin?
    raise ModerationError, I18n.t("admin.users.errors.must_demote_admin_first") if role == "admin"
    raise ModerationError, I18n.t("admin.users.errors.not_moderatable") unless role == "user"
  end
end
