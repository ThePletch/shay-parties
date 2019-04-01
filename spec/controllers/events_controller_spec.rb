require 'rails_helper'

describe EventsController do

  describe "GET index" do
    before do
      # we make both to test 'wrong user' cases more thoroughly
      @non_default_user = FactoryBot.create(:user)
      @default_user = FactoryBot.create(:user, default_host: true)
    end

    context "with unspecified user" do
      it "shows all events for default host with end times after the current time" do
        earlier_event = FactoryBot.create(:event, start_time: Time.current - 25.hours, end_time: Time.current - 1.day, owner: @default_user)
        later_event = FactoryBot.create(:event, start_time: Time.current, end_time: Time.current + 1.day, owner: @default_user)
        later_non_default = FactoryBot.create(:event, start_time: Time.current, end_time: Time.current + 1.day, owner: @non_default_user)

        get :index
        expect(assigns(:events)).to match_array([later_event])
      end

      it "shows all past events for default host when set to 'past' scope" do
        earlier_non_default = FactoryBot.create(:event, start_time: Time.current - 25.hours, end_time: Time.current - 1.day, owner: @non_default_user)
        earlier_event = FactoryBot.create(:event, start_time: Time.current - 25.hours, end_time: Time.current - 1.day, owner: @default_user)
        later_event = FactoryBot.create(:event, start_time: Time.current, end_time: Time.current + 1.day, owner: @default_user)

        get :index, params: {scope: :past}
        expect(assigns(:events)).to match_array([earlier_event])
      end
    end

    context "with specified user" do
      it "shows all events for specified user with end times after the current time" do
        earlier_event = FactoryBot.create(:event, start_time: Time.current - 25.hours, end_time: Time.current - 1.day, owner: @default_user)
        later_event = FactoryBot.create(:event, start_time: Time.current, end_time: Time.current + 1.day, owner: @default_user)
        later_non_default = FactoryBot.create(:event, start_time: Time.current, end_time: Time.current + 1.day, owner: @non_default_user)

        get :index, params: {user_id: @non_default_user.id}
        expect(assigns(:events)).to match_array([later_non_default])
      end

      it "shows all past events for specified user when set to 'past' scope" do
        earlier_non_default = FactoryBot.create(:event, start_time: Time.current - 25.hours, end_time: Time.current - 1.day, owner: @non_default_user)
        earlier_event = FactoryBot.create(:event, start_time: Time.current - 25.hours, end_time: Time.current - 1.day, owner: @default_user)
        later_event = FactoryBot.create(:event, start_time: Time.current, end_time: Time.current + 1.day, owner: @default_user)

        get :index, params: {scope: :past, user_id: @non_default_user.id}
        expect(assigns(:events)).to match_array([earlier_non_default])
      end
    end
  end

  describe "GET show" do
    it "finds an event"
    it "errors if there is no such event"
  end

  describe "GET edit" do
    # this will change when we switch to scoped indexes
    it "redirects to the index page if the user can't make events"
    it "redirects to the index page if the user doesn't own the event"
    it "finds an event and builds an address for it if it doesn't have one"
  end

  describe "POST create" do
    # this will change when we switch to scoped indexes
    it "redirects to the index page if the user can't make events"
    it "creates the event"
    # validation spec, specific validation being tested is arbitrary
    it "does not create events that start after they end"
  end

  describe "PATCH update" do
    # this will change when we switch to scoped indexes
    it "redirects to the index page if the user can't make events"
    it "redirects to the index page if the user doesn't own the event"
    it "updates the event"
  end

  describe "DELETE destroy" do
    it "redirects to the index page if the user doesn't own the event"
    it "deletes the event"
  end

end
