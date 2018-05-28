require 'rails_helper'

describe PollResponsesController do

  describe "POST create" do
    it "redirects to the login page when unauthenticated"
    context "with a logged in user" do
      it "creates a poll response"
      it "updates the existing response for a poll if the user has one"
    end
  end

  describe "PATCH update" do
    it "redirects to the login page when unauthenticated"
    context "with a logged in user" do
      it "updates the response choice"
      it "creates a new rsvp if the target attendance doesn't exist"
    end
  end

end
