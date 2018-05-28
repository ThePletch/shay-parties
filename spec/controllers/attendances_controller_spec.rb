require 'rails_helper'

describe AttendancesController do

  describe "POST create" do
    it "redirects to the login page when unauthenticated"
    context "with a logged in user" do
      it "creates an attendance"
      it "updates the existing attendance for an event if the user has one"
    end
  end

  describe "PATCH update" do
    it "redirects to the login page when unauthenticated"
    context "with a logged in user" do
      it "deletes the rsvp if status is 'no rsvp'"
      it "updates the rsvp status"
      it "creates a new rsvp if the target attendance doesn't exist"
    end
  end

end
