# frozen_string_literal: true

class BannedEmail < ApplicationRecord
  belongs_to :banned_by, class_name: "User", optional: true

  before_validation :normalize_email

  validates :email, presence: true, uniqueness: true

  def self.normalize(email)
    email.to_s.strip.downcase
  end

  def self.banned?(email)
    exists?(email: normalize(email))
  end

  def self.ban!(email, banned_by: nil, reason: nil)
    record = find_or_initialize_by(email: normalize(email))
    record.banned_by = banned_by if banned_by
    record.reason = reason if reason.present?
    record.save!
    record
  end

  private

  def normalize_email
    self.email = self.class.normalize(email)
  end
end
