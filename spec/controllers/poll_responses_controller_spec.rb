require 'rails_helper'

describe PollResponsesController do

  describe "POST create" do
    before do
      @poll = FactoryBot.create(:poll)
      @poll_option = FactoryBot.create(:poll_option, poll: @poll)
    end

    context "unauthenticated" do
      it "redirects to the login page when no guest guid" do
        post :create, params: {poll_id: @poll.id, poll_response: {poll_option_id: @poll_option.id}}
        expect(response).to redirect_to new_user_session_path
      end

      it "redirects to the login page when invalid guest guid" do
        post :create, params: {poll_id: @poll.id, guest_guid: SecureRandom.uuid, poll_response: {poll_option_id: @poll_option.id}}
        expect(response).to redirect_to new_user_session_path
      end

      context "with a valid guest guid" do
        before do
          @guest = FactoryBot.create(:guest)
        end

        it "creates a poll response" do
          post :create, params: {poll_id: @poll.id, guest_guid: @guest.guid, poll_response: {poll_option_id: @poll_option.id}}
        end
      end
    end

    context "with a logged in user" do
      before do
        @user = FactoryBot.create(:user)
        @poll = FactoryBot.create(:poll)
        @poll_option = FactoryBot.create(:poll_option, poll: @poll)
        sign_in @user
      end

      it "creates a poll response" do
        post :create, params: {poll_id: @poll.id, poll_response: {poll_option_id: @poll_option.id}}
        poll_response = @poll.response_for_respondent(@user)
        expect(poll_response).not_to be_nil

        expect(poll_response.poll_option).to eq @poll_option
      end

      it "creates a new 'maybe' rsvp if the user hasn't rsvped" do
        post :create, params: {poll_id: @poll.id, poll_response: {poll_option_id: @poll_option.id}}

        attendance = @user.attendances.find_by(event_id: @poll.event.id)
        expect(attendance).not_to be_nil
        expect(attendance.rsvp_status).to eq "Maybe"
      end

      it "does not overwrite existing rsvps" do
        FactoryBot.create(:attendance, attendee: @user, event: @poll.event, rsvp_status: 'Yes')
        post :create, params: {poll_id: @poll.id, poll_response: {poll_option_id: @poll_option.id}}

        attendance = @user.attendances.find_by(event_id: @poll.event.id)
        expect(attendance.rsvp_status).to eq "Yes"
      end
    end
  end

  describe "PATCH update" do

    context "unauthenticated" do
      before do
        @response = FactoryBot.create(:poll_response)
        @other_option = FactoryBot.create(:poll_option, poll: @response.poll)
      end

      it "redirects to the login page when no guest guid" do
        patch :update, params: {id: @response.id, poll_response: {poll_option_id: @other_option.id}}
        expect(response).to redirect_to new_user_session_path
      end

      it "redirects to the login page when invalid guest guid" do
        patch :update, params: {id: @response.id, guest_guid: SecureRandom.uuid, poll_response: {poll_option_id: @other_option.id}}
        expect(response).to redirect_to new_user_session_path
      end

      context "with a valid guest guid" do
        before do
          @guest = FactoryBot.create(:guest)
        end

        it "errors if the guest does not own the poll response" do
          expect do
            patch :update, params: {id: @response.id, guest_guid: @guest.guid, poll_response: {poll_option_id: @other_option.id}}
          end.to raise_error(ActiveRecord::RecordNotFound)
        end

        it "updates the poll response if the guest owns it" do
          owned_response = FactoryBot.create(:poll_response, respondent: @guest)
          other_option = FactoryBot.create(:poll_option, poll: owned_response.poll)
          patch :update, params: {id: owned_response.id, guest_guid: @guest.guid, poll_response: {poll_option_id: other_option.id}}
          expect(owned_response.reload.poll_option).to eq other_option
        end
      end
    end

    context "with a logged in user" do
      before do
        @user = FactoryBot.create(:user)
        sign_in @user
        @poll_response = FactoryBot.create(:poll_response, respondent: @user)
        @other_option = FactoryBot.create(:poll_option, poll: @poll_response.poll)
      end

      it "errors if the user does not own the response" do
        unowned_response = FactoryBot.create(:poll_response)
        expect do
          patch :update, params: {id: unowned_response.id, poll_response: {poll_option_id: @other_option.id}}
        end.to raise_error(ActiveRecord::RecordNotFound)
      end

      it "updates the selected option" do
        patch :update, params: {id: @poll_response.id, poll_response: {poll_option_id: @other_option.id}}
        expect(@poll_response.reload.poll_option).to eq @other_option
      end

      it "creates a new 'maybe' rsvp if the user hasn't rsvped" do
        patch :update, params: {id: @poll_response.id, poll_response: {poll_option_id: @other_option.id}}

        attendance = @user.attendances.find_by(event_id: @poll_response.poll.event.id)
        expect(attendance).not_to be_nil
        expect(attendance.rsvp_status).to eq "Maybe"
      end

      it "does not overwrite existing rsvps" do
        FactoryBot.create(:attendance, attendee: @user, event: @poll_response.poll.event, rsvp_status: 'Yes')
        patch :update, params: {id: @poll_response.id, poll_response: {poll_option_id: @other_option.id}}

        attendance = @user.attendances.find_by(event_id: @poll_response.poll.event.id)
        expect(attendance.rsvp_status).to eq "Yes"
      end
    end
  end

end
