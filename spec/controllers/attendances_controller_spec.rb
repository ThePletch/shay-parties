require 'rails_helper'

describe AttendancesController do

  describe "POST create" do
    before do
      @event = FactoryBot.create(:event)
    end

    context "when unauthenticated" do
      it "rejects requests with no guest information" do
        post :create, params: {event_id: @event.id, attendance: {rsvp_status: "Yes"}, attendee: {name: nil, email: nil}}
        expect(response).to redirect_to event_path(@event)
        expect(@event.attendances).to be_empty
      end

      it "registers a guest attendance when info is provided" do
        post :create, params: {
          event_id: @event.id,
          attendance: {rsvp_status: "Yes"},
          attendee: {name: "Steve", email: "steve@steve.steve"}}
        expect(@event.attendances.count).to eq 1
        guest = @event.attendances.first.attendee
        expect(guest).to be_a Guest
        expect(guest.name).to eq "Steve"
        expect(guest.email).to eq "steve@steve.steve"
        expect(response).to redirect_to(event_path(@event, guest_guid: guest.guid))
      end
    end

    context "with a logged in user" do
      before do
        @user = FactoryBot.create(:user)
        sign_in @user
      end

      it "creates an attendance" do
        post :create, params: {
          event_id: @event.id,
          attendance: {rsvp_status: "Yes"}
        }
        expect(@event.attendances.count).to eq 1
        user = @event.attendances.first.attendee
        expect(user).to be_a User
        expect(user).to eq @user
        expect(response).to redirect_to(event_path(@event))
      end
    end
  end

  describe "PATCH update" do
    before do
      @event = FactoryBot.create(:event)
    end

    context "unauthenticated" do
      it "redirects to the login page when no guest guid" do
        attendance = FactoryBot.create(:attendance, event: @event)
        patch :update, params: {id: attendance.id, attendance: {rsvp_status: 'No'}}
        expect(response).to redirect_to(new_user_session_path)
      end

      it "redirects to the login page when invalid guest guid" do
        attendance = FactoryBot.create(:attendance, event: @event)
        patch :update, params: {id: attendance.id, guest_guid: SecureRandom.uuid, attendance: {rsvp_status: 'No'}}
        expect(response).to redirect_to(new_user_session_path)
      end

      context "with a valid guest guid" do
        before do
          @attendance = FactoryBot.create(:guest_attendance, event: @event, rsvp_status: 'Yes')
          @guest = @attendance.attendee
        end

        it "deletes the rsvp and guest if status is 'no rsvp'" do
          patch :update, params: {
            id: @attendance.id,
            guest_guid: @guest.guid,
            attendance: {rsvp_status: 'No RSVP'}
          }
          expect(response).to redirect_to(event_path(@event))
          expect(Attendance.find_by(id: @attendance.id)).to be_nil
          expect(Guest.find_by(id: @guest.id)).to be_nil
        end

        it "updates the rsvp status" do
          patch :update, params: {
            id: @attendance.id,
            guest_guid: @guest.guid,
            attendance: {rsvp_status: 'Maybe'}
          }
          expect(response).to redirect_to(event_path(@event, guest_guid: @guest.guid))
          expect(@attendance.reload.rsvp_status).to eq 'Maybe'
        end

        it "does not alter other RSVPs for guests or users" do
          some_other_attendance = FactoryBot.create(:attendance, event: @event, rsvp_status: 'Yes')
          some_guest_attendance = FactoryBot.create(:guest_attendance, event: @event, rsvp_status: 'Yes')
          patch :update, params: {
            id: @attendance.id,
            guest_guid: @guest.guid,
            attendance: {rsvp_status: 'Maybe'}
          }
          expect(response).to redirect_to(event_path(@event, guest_guid: @guest.guid))
          expect(@attendance.reload.rsvp_status).to eq 'Maybe'
          expect(some_other_attendance.reload.rsvp_status).to eq 'Yes'
          expect(some_guest_attendance.reload.rsvp_status).to eq 'Yes'
        end
      end
    end

    context "with a logged in user" do
      before do
        @attendance = FactoryBot.create(:attendance, event: @event)
        @user = @attendance.attendee
        sign_in @user
      end

      it "deletes the rsvp if status is 'no rsvp'" do
        patch :update, params: {
          id: @attendance.id,
          attendance: {rsvp_status: 'No RSVP'}
        }
        expect(response).to redirect_to(event_path(@event))
        expect(Attendance.find_by(id: @attendance.id)).to be_nil
        # make sure it doesn't delete the user, since there's logic to delete guests
        expect(User.find_by(id: @user.id)).to eq @user
      end

      it "updates the rsvp status" do
        patch :update, params: {
          id: @attendance.id,
          attendance: {rsvp_status: 'Maybe'}
        }
        expect(response).to redirect_to(event_path(@event))
        expect(@attendance.reload.rsvp_status).to eq 'Maybe'
      end
    end
  end

  describe "DELETE destroy" do
    before do
      @event = FactoryBot.create(:event)
    end

    context "unauthenticated" do
      it "redirects to the login page when no guest guid" do
        attendance = FactoryBot.create(:attendance, event: @event)
        delete :destroy, params: {id: attendance.id}
        expect(response).to redirect_to(new_user_session_path)
      end

      it "redirects to the login page when invalid guest guid" do
        attendance = FactoryBot.create(:attendance, event: @event)
        delete :destroy, params: {id: attendance.id, guest_guid: SecureRandom.uuid}
        expect(response).to redirect_to(new_user_session_path)
      end

      context "with a valid guest guid" do
        before do
          @attendance = FactoryBot.create(:guest_attendance, event: @event, rsvp_status: 'Yes')
          @guest = @attendance.attendee
        end

        it "redirects to the event page if the guest does not own the rsvp" do
          some_other_attendance = FactoryBot.create(:guest_attendance, event: @event)
          delete :destroy, params: {
            id: some_other_attendance.id,
            guest_guid: @guest.guid
          }
          expect(response).to redirect_to(event_path(@event, guest_guid: @guest.guid))
          expect(Attendance.find_by(id: some_other_attendance.id)).to be_persisted
        end

        it "deletes the rsvp" do
          delete :destroy, params: {
            id: @attendance.id,
            guest_guid: @guest.guid
          }
          expect(response).to redirect_to(event_path(@event))
          expect(Attendance.find_by(id: @attendance.id)).to be_nil
          expect(Guest.find_by(id: @guest.id)).to be_nil
        end
      end

      context "with a logged in user" do
        before do
          @user = FactoryBot.create(:user)
          sign_in @user
        end

        it "redirects to the event page if the user does not own the rsvp" do
          some_other_attendance = FactoryBot.create(:attendance, event: @event)
          delete :destroy, params: {
            id: some_other_attendance.id
          }
          expect(response).to redirect_to(event_path(@event))
          expect(Attendance.find_by(id: some_other_attendance.id)).to be_persisted
        end

        it "deletes the rsvp if the user owns the rsvp" do
          attendance = FactoryBot.create(:attendance, attendee: @user, event: @event)
          delete :destroy, params: {
            id: attendance.id
          }
          expect(response).to redirect_to(event_path(@event))
          expect(Attendance.find_by(id: attendance.id)).to be_nil
        end

        it "deletes the rsvp if the user owns the event" do
          owned_event = FactoryBot.create(:event, owner: @user)
          attendance = FactoryBot.create(:attendance, event: owned_event)

          delete :destroy, params: {
            id: attendance.id
          }
          expect(response).to redirect_to(event_path(owned_event))
          expect(Attendance.find_by(id: attendance.id)).to be_nil
        end
      end
    end
  end

end
