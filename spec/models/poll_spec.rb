require 'rails_helper'

describe Poll do

  describe "#responses_and_counts" do
    it "does not include example responses in counts" do
      poll = FactoryBot.create(:poll)
      FactoryBot.create(:poll_response, poll: poll, example_response: true, choice: 'steve')
      FactoryBot.create(:poll_response, poll: poll, example_response: false, choice: 'steve')

      expect(poll.responses_and_counts['steve']).to eq 1
    end

    it "still includes responses with no actual responses, but with count zero" do
      poll = FactoryBot.create(:poll)
      FactoryBot.create(:poll_response, poll: poll, example_response: true, choice: 'steve')

      expect(poll.responses_and_counts['steve']).to eq 0
    end

    it "returns the count for each response" do
      poll = FactoryBot.create(:poll)
      FactoryBot.create(:poll_response, poll: poll, example_response: false, choice: 'steve')
      FactoryBot.create(:poll_response, poll: poll, example_response: false, choice: 'other steve')
      FactoryBot.create(:poll_response, poll: poll, example_response: false, choice: 'mega steve')
      FactoryBot.create(:poll_response, poll: poll, example_response: false, choice: 'mega steve')

      counts = poll.responses_and_counts
      expect(counts.keys).to match_array(['steve', 'other steve', 'mega steve'])
      expect(counts['steve']).to eq 1
      expect(counts['other steve']).to eq 1
      expect(counts['mega steve']).to eq 2
    end
  end

  describe "#response_for_respondent" do
    it "returns a new response if no response exists" do
      user = FactoryBot.create(:user)
      poll = FactoryBot.create(:poll)

      expect(poll.response_for_respondent(user)).not_to be_persisted
    end

    it "returns a new response if the user does not exist" do
      poll = FactoryBot.create(:poll)

      expect(poll.response_for_respondent(nil)).not_to be_persisted
    end

    it "returns the response for a guest if one exists" do
      guest = FactoryBot.create(:guest)
      poll_response = FactoryBot.create(:poll_response, respondent: guest)
      expect(poll_response.poll.response_for_respondent(guest)).to eq poll_response
    end

    it "returns the response for a user if one exists" do
      user = FactoryBot.create(:user)
      poll_response = FactoryBot.create(:poll_response, respondent: user)
      expect(poll_response.poll.response_for_respondent(user)).to eq poll_response
    end
  end

end
