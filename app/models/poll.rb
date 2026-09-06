class Poll < ApplicationRecord
  include Ownable

  belongs_to :event
  has_many :options, -> { order(:id) }, class_name: "PollOption", dependent: :destroy, inverse_of: :poll
  has_many :responses, through: :options

  validates :question, presence: true

  accepts_nested_attributes_for :options, allow_destroy: true

  def responses_and_counts
    options.each_with_object({}) do |option, tallies|
      tallies[option] = option.responses.size
    end
  end

  def response_for_respondent(respondent)
    return PollResponse.new if respondent.nil?

    responses.find_by(respondent: respondent) || PollResponse.new
  end
end
