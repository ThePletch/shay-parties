class PollOption < ApplicationRecord
  belongs_to :poll, inverse_of: :options
  has_many :responses, class_name: "PollResponse", dependent: :destroy, inverse_of: :poll_option

  validates :choice, presence: true
end
