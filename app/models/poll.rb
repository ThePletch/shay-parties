class Poll < ApplicationRecord
  include Ownable

  belongs_to :event
  has_many :responses, class_name: "PollResponse", dependent: :destroy

  validates :question, presence: true

  accepts_nested_attributes_for :responses, allow_destroy: true

  def responses_and_counts
    responses.group_by(&:choice).transform_values do |resps|
      resps.reject(&:example_response).count
    end
  end

  def response_for_respondent(respondent)
    return PollResponse.new if respondent.nil?

    responses.find_by(respondent: respondent) || PollResponse.new
  end
end
