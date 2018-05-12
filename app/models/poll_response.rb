class PollResponse < ApplicationRecord
  belongs_to :user
  belongs_to :poll
  has_one :event, through: :poll

  scope :example, -> { where(example_response: true) }
  scope :non_example, -> { where(example_response: false) }
end
