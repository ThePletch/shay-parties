class MailingList < ApplicationRecord
  belongs_to :user
  has_many :emails, class_name: "MailingListEmail", dependent: :destroy

  validates :name, presence: true

  accepts_nested_attributes_for :emails, allow_destroy: true

  def sync_users(force: false)
    emails.each{|email| email.match_to_user(force: force) }
  end

  def add_addresses(text)
    existing = emails.pluck(:email).map { |email| email.to_s.downcase }
    added = []
    invalid = []

    transaction do
      parsed_addresses(text).each do |address|
        if existing.include?(address)
          next
        elsif address.match?(URI::MailTo::EMAIL_REGEXP)
          emails.create!(email: address)
          existing << address
          added << address
        else
          invalid << address
        end
      end
    end

    { added: added, invalid: invalid }
  end

  private

  def parsed_addresses(text)
    text.to_s.split(/[\s,;]+/).filter_map do |value|
      address = value.strip.downcase
      address.presence
    end.uniq
  end
end
