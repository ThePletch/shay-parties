require 'rails_helper'

describe EventsController do

  describe "GET attendee_index" do
    it "redirects to the login page when not logged in" do
      get :attendee_index
      expect(response).to redirect_to new_user_session_path
    end

    context "logged in" do
      before do
        @user = FactoryBot.create(:user)
        sign_in @user
        @later_event = FactoryBot.create(:event, start_time: Time.current, end_time: Time.current + 1.day)
        FactoryBot.create(:attendance, event: @later_event, attendee: @user)
        @later_event_unrsvped = FactoryBot.create(:event, start_time: Time.current, end_time: Time.current + 1.day)
        @earlier_event = FactoryBot.create(:event, start_time: Time.current - 25.hours, end_time: Time.current - 1.day)
        FactoryBot.create(:attendance, event: @earlier_event, attendee: @user)
        @earlier_event_unrsvped = FactoryBot.create(:event, start_time: Time.current - 25.hours, end_time: Time.current - 1.day)
      end

      it "shows future events the user has RSVPed to" do
        get :attendee_index
        expect(assigns(:events)).to match_array([@later_event])
      end

      it "shows past events the user has RSVPed to when past scope specified" do
        get :attendee_index, params: {scope: :past}
        expect(assigns(:events)).to match_array([@earlier_event])
      end
    end
  end

  describe "GET host_index" do
    before do
      @user_a = FactoryBot.create(:user)
      @user_b = FactoryBot.create(:user)
    end

    it "redirects to the login page when not logged in" do
      get :host_index
      expect(response).to redirect_to new_user_session_path
    end

    context "logged in" do
      before do
        sign_in @user_a
      end

      it "shows the current user's future hosted events" do
        FactoryBot.create(:event, start_time: Time.current - 25.hours, end_time: Time.current - 1.day, owner: @user_a)
        later_event = FactoryBot.create(:event, start_time: Time.current, end_time: Time.current + 1.day, owner: @user_a)
        FactoryBot.create(:event, start_time: Time.current, end_time: Time.current + 1.day, owner: @user_b)

        get :host_index
        expect(assigns(:events)).to match_array([later_event])
      end

      it "shows the current user's past hosted events when set to 'past' scope" do
        earlier_a = FactoryBot.create(:event, start_time: Time.current - 25.hours, end_time: Time.current - 1.day, owner: @user_a)
        FactoryBot.create(:event, start_time: Time.current - 25.hours, end_time: Time.current - 1.day, owner: @user_b)
        FactoryBot.create(:event, start_time: Time.current, end_time: Time.current + 1.day, owner: @user_a)

        get :host_index, params: {scope: :past}
        expect(assigns(:events)).to match_array([earlier_a])
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
          start_time:,
          end_time: Time.current,
        }}
        expect(response).to redirect_to(event_path(assigns(:event)))
        expect(assigns(:event)).to be_persisted
        expect(assigns(:event).title).to eq 'foobar'
        expect(assigns(:event).start_time).to be_within(1.minute).of(start_time)
      end

      it "blocks unconfirmed users from creating events" do
        unconfirmed = FactoryBot.create(:user, :unconfirmed)
        sign_in unconfirmed

        expect {
          post :create, params: {event: {
            title: 'foobar',
            start_time: 10.minutes.ago,
            end_time: Time.current,
          }}
        }.not_to change(Event, :count)

        expect(flash[:alert]).to eq(I18n.t('user.rejection.unconfirmed'))
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

  describe "GET new" do
    it "blocks unconfirmed users" do
      user = FactoryBot.create(:user, :unconfirmed)
      sign_in user

      get :new

      expect(response).to redirect_to(root_path)
      expect(flash[:alert]).to eq(I18n.t('user.rejection.unconfirmed'))
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

    it "deletes the event and redirects to the host's events list" do
      event = FactoryBot.create(:event)
      sign_in event.owner
      delete :destroy, params: {id: event.id}

      expect(Event.find_by(id: event.id)).to be_nil
      expect(response).to redirect_to(hosted_events_path)
    end
  end

end
