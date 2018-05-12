class Poll < ApplicationRecord
  include Ownable

  belongs_to :event
  has_many :responses, class_name: "PollResponse", dependent: :destroy
  has_many :users, through: :responses

  accepts_nested_attributes_for :responses, allow_destroy: true

  def responses_and_counts
    responses.group_by(&:choice).transform_values do |resps|
      resps.reject(&:example_response).count
    end
  end

  def response_for_user(user)
    return PollResponse.new if user.nil?

    responses.find_by(user: user) || PollResponse.new
  end
end
