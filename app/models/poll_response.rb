class PollResponse < ApplicationRecord
  belongs_to :poll_option, inverse_of: :responses, optional: false
  belongs_to :respondent, polymorphic: true
  has_one :poll, through: :poll_option
  has_one :event, through: :poll
end
