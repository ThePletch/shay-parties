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
    it "finds an event" do
      event = FactoryBot.create(:event)
      get :show, params: {id: event.id}
      expect(assigns(:event)).to eq event
    end

    it "errors if there is no such event" do
      expect { get :show, params: {id: 999999} }.to raise_error(ActiveRecord::RecordNotFound)
    end
  end

  describe "GET edit" do
    it "errors if the user doesn't own the event" do
      event = FactoryBot.create(:event)
      user = FactoryBot.create(:user)
      sign_in user

      expect { get :edit, params: {id: event.id} }.to raise_error(ActiveRecord::RecordNotFound)
    end

    it "finds an event and builds an address for it if it doesn't have one" do
      event = FactoryBot.create(:event, address: nil)
      sign_in event.owner

      get :edit, params: {id: event.id}
      expect(assigns(:event)).to eq event
      expect(assigns(:event).address).to be_a_new(Address)
    end
  end

  describe "POST create" do
    it "redirects to the login page if unauthenticated" do
      post :create, params: {event: {}}
      expect(response).to redirect_to(new_user_session_path)
    end

    context "authenticated" do
      before do
        @user = FactoryBot.create(:user)
        sign_in @user
      end

      it "creates the event" do
        start_time = 10.minutes.ago
        post :create, params: {event: {
          title: 'foobar',
          start_time: start_time.strftime(Event::TIMESTAMP_FORMAT),
          end_time: Time.current.strftime(Event::TIMESTAMP_FORMAT),
        }}
        expect(response).to redirect_to(event_path(assigns(:event)))
        expect(assigns(:event)).to be_persisted
        expect(assigns(:event).title).to eq 'foobar'
        expect(assigns(:event).start_time).to be_within(1.minute).of(start_time)
      end

      # validation spec, specific validation being tested is arbitrary
      it "does not create events that start after they end" do
        end_time = 10.minutes.ago
        start_time = Time.current
        post :create, params: {event: {
          title: 'foobar',
          start_time: start_time.strftime(Event::TIMESTAMP_FORMAT),
          end_time: end_time.strftime(Event::TIMESTAMP_FORMAT),
        }}

        expect(Event.all).to be_empty
        expect(assigns(:event)).not_to be_persisted
        expect(assigns(:event)).not_to be_valid
      end
    end
  end

  describe "PATCH update" do
    it "errors if the user doesn't own the event" do
      event = FactoryBot.create(:event)
      user = FactoryBot.create(:user)
      sign_in user

      expect { patch :update, params: {id: event.id} }.to raise_error(ActiveRecord::RecordNotFound)
    end

    it "updates the event" do
      event = FactoryBot.create(:event)
      new_title = event.title + " AAAAA"
      sign_in event.owner
      patch :update, params: {id: event.id, event: {
        title: new_title
      }}

      expect(event.reload.title).to eq new_title
    end
  end

  describe "DELETE destroy" do
    it "errors if the user doesn't own the event" do
      event = FactoryBot.create(:event)
      user = FactoryBot.create(:user)
      sign_in user

      expect { delete :destroy, params: {id: event.id} }.to raise_error(ActiveRecord::RecordNotFound)
    end

    it "deletes the event" do
      event = FactoryBot.create(:event)
      sign_in event.owner
      delete :destroy, params: {id: event.id}

      expect(Event.find_by(id: event.id)).to be_nil
    end
  end

end
