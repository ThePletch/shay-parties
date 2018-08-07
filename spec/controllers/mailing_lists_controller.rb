require 'rails_helper'

describe MailingListsController do
  def login_user(user = nil)
    @request.env["devise.mapping"] = Devise.mappings[:user]
    @user = user || FactoryBot.create(:user)
    sign_in @user
  end

  def login_creator
    login_user(FactoryBot.create(:user, role: :creator))
  end

  describe "GET show" do
    it "redirects away non-logged-in users" do
      get :show, params: {id: 12345}
      expect(response).to redirect_to new_user_session_path
      expect(flash[:alert]).to include "You need to sign in"
    end

    it "redirects away non-creators" do
      login_user
      get :show, params: {id: 12345}
      expect(response).to redirect_to root_path
      expect(flash[:alert]).to include "You're not allowed to manage mailing lists"
    end

    context "authenticated as a creator" do
      before :each do
        login_creator
      end

      it "errors if there is no such mailing list" do
        expect do
          get :show, params: {id: 12345}
        end.to raise_error(ActiveRecord::RecordNotFound)
      end

      it "errors if the mailing list is not owned by the current user" do
        list = FactoryBot.create(:mailing_list)
        expect do
          get :show, params: {id: list.id}
        end.to raise_error(ActiveRecord::RecordNotFound)
      end

      it "shows a mailing list" do
        list = FactoryBot.create(:mailing_list, user: @user)

        expect do
          get :show, params: {id: list.id}
        end.not_to raise_error
      end

      context "email scoping" do
        before :each do
          @attendees = FactoryBot.create_list(:user, 3)
          @mailing_list = FactoryBot.create(:mailing_list, user: @user, emails: @attendees.map(&:email))
          @mailing_list.sync_users
        end

        it "shows all emails if no scope is applied" do
          get :show, params: {id: @mailing_list.id}
          expect(assigns(:emails)).to match_array(@mailing_list.emails.where(user_id: @attendees.map(&:id)))
        end

        it "omits declined rsvps for exclude_no_rsvps" do
          event = FactoryBot.create(:event)
          not_attending = @attendees.first
          FactoryBot.create(:attendance, invitable: not_attending, attendable: event, rsvp_status: "No")

          expected_shows = @mailing_list.emails.where(user_id: @attendees.map(&:id) - [not_attending.id])
          get :show, params: {id: @mailing_list.id, scope: 'exclude_no_rsvps', event_id: event.id}
          expect(assigns(:emails)).to match_array(expected_shows)
        end

        it "shows only rsvped attendees for attendees" do
          event = FactoryBot.create(:event)
          attending = @attendees.first
          FactoryBot.create(:attendance, invitable: attending, attendable: event, rsvp_status: "Yes")

          expected_shows = @mailing_list.emails.where(user_id: attending.id)
          get :show, params: {id: @mailing_list.id, scope: 'attendees', event_id: event.id}
          expect(assigns(:emails)).to match_array(expected_shows)
        end
      end
    end
  end
end
