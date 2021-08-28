class PollResponse < ApplicationRecord
  belongs_to :respondent, polymorphic: true
  belongs_to :poll
  has_one :event, through: :poll

  validates :choice, presence: true

  scope :example, -> { where(example_response: true) }
  scope :non_example, -> { where(example_response: false) }
end
