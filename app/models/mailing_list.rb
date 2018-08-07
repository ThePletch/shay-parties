class MailingList < ApplicationRecord
  belongs_to :user
  has_many :emails, class_name: "MailingListEmail", dependent: :destroy

  validates :name, presence: true

  accepts_nested_attributes_for :emails, allow_destroy: true

  # links any emails that match existing users to those users
  def sync_users(force: false)
    emails.each{|email| email.match_to_user(force: force) }
  end
end
