require 'rails_helper'

describe PollResponsesController do

  describe "POST create" do
    it "redirects to the login page when unauthenticated" do
      post :create, params: {poll_id: 123, choice: 'aeiou'}
      expect(response).to redirect_to new_user_session_path
    end

    context "with a logged in user" do
      before do
        @user = FactoryBot.create(:user)
        @poll = FactoryBot.create(:poll)
        sign_in @user
      end

      it "creates a poll response" do
        post :create, params: {poll_id: @poll.id, poll_response: {choice: 'aeiou', example_response: false}}
        response = @poll.response_for_user(@user)
        expect(response).not_to be_nil

        expect(response.choice).to eq 'aeiou'
      end

      it "creates a new 'maybe' rsvp if the user hasn't rsvped" do
        post :create, params: {poll_id: @poll.id, poll_response: {choice: 'aeiou', example_response: false}}

        attendance = @user.attendances.find_by(event_id: @poll.event.id)
        expect(attendance).not_to be_nil
        expect(attendance.rsvp_status).to eq "Maybe"
      end

      it "does not overwrite existing rsvps" do
        FactoryBot.create(:attendance, attendee: @user, event: @poll.event, rsvp_status: 'Yes')
        post :create, params: {poll_id: @poll.id, poll_response: {choice: 'aeiou', example_response: false}}

        attendance = @user.attendances.find_by(event_id: @poll.event.id)
        expect(attendance.rsvp_status).to eq "Yes"
      end
    end
  end

  describe "PATCH update" do
    it "redirects to the login page when unauthenticated" do
      poll_response = FactoryBot.create(:poll_response)
      patch :update, params: {id: poll_response.id}
      expect(response).to redirect_to new_user_session_path
    end

    context "with a logged in user" do
      before do
        @user = FactoryBot.create(:user)
        sign_in @user
        @poll_response = FactoryBot.create(:poll_response, user: @user, choice: 'blaeiou')
      end

      it "updates the response choice" do
        patch :update, params: {id: @poll_response.id, poll_response: {choice: 'aeiou', example_response: false}}
        expect(@poll_response.reload.choice).to eq 'aeiou'
      end

      it "creates a new 'maybe' rsvp if the user hasn't rsvped" do
        patch :update, params: {id: @poll_response.id, poll_response: {choice: 'aeiou', example_response: false}}

        attendance = @user.attendances.find_by(event_id: @poll_response.poll.event.id)
        expect(attendance).not_to be_nil
        expect(attendance.rsvp_status).to eq "Maybe"
      end

      it "does not overwrite existing rsvps" do
        FactoryBot.create(:attendance, attendee: @user, event: @poll_response.poll.event, rsvp_status: 'Yes')
        patch :update, params: {id: @poll_response.id, poll_response: {choice: 'aeiou', example_response: false}}

        attendance = @user.attendances.find_by(event_id: @poll_response.poll.event.id)
        expect(attendance.rsvp_status).to eq "Yes"
      end
    end
  end

end
