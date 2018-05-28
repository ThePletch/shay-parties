require 'rails_helper'

describe Poll do

  describe "#responses_and_counts" do
    it "does not include example responses in counts"
    it "still includes responses with no actual responses, but with count zero"
    it "returns the count for each response"
  end

  describe "#response_for_user" do
    it "returns a new response if no response exists"
    it "returns a new response if the user does not exist"
    it "returns the response for a user if one exists"
  end

end
