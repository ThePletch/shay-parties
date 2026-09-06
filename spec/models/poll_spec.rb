require 'rails_helper'

describe Poll do

  describe "#responses_and_counts" do
    it "counts responses against their options" do
      poll = FactoryBot.create(:poll)
      option = FactoryBot.create(:poll_option, poll: poll, choice: 'steve')
      FactoryBot.create(:poll_response, poll_option: option)

      expect(poll.responses_and_counts[option]).to eq 1
    end

    it "still includes options with no actual responses, but with count zero" do
      poll = FactoryBot.create(:poll)
      option = FactoryBot.create(:poll_option, poll: poll, choice: 'steve')

      expect(poll.responses_and_counts[option]).to eq 0
    end

    it "keeps counts on an option after its text is edited" do
      poll = FactoryBot.create(:poll)
      option = FactoryBot.create(:poll_option, poll: poll, choice: 'steve')
      FactoryBot.create(:poll_response, poll_option: option)

      option.update!(choice: 'steven')

      counts = poll.reload.responses_and_counts
      expect(counts.keys.map(&:choice)).to eq ['steven']
      expect(counts[option.reload]).to eq 1
    end

    it "returns the count for each option" do
      poll = FactoryBot.create(:poll)
      steve = FactoryBot.create(:poll_option, poll: poll, choice: 'steve')
      other_steve = FactoryBot.create(:poll_option, poll: poll, choice: 'other steve')
      mega_steve = FactoryBot.create(:poll_option, poll: poll, choice: 'mega steve')
      FactoryBot.create(:poll_response, poll_option: steve)
      FactoryBot.create(:poll_response, poll_option: other_steve)
      FactoryBot.create_list(:poll_response, 2, poll_option: mega_steve)

      counts = poll.responses_and_counts
      expect(counts.keys).to eq [steve, other_steve, mega_steve]
      expect(counts[steve]).to eq 1
      expect(counts[other_steve]).to eq 1
      expect(counts[mega_steve]).to eq 2
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
