class Guest < ApplicationRecord
    has_many :attendances, as: :attendee, dependent: :destroy
    has_many :events, through: :attendances

    validates :name, presence: true
    validates :email, presence: true

    before_create :generate_guid

    private

    def generate_guid
        self.guid = SecureRandom.uuid
    end
end
