require "rails_helper"

describe CommentsController do
  let(:event) { FactoryBot.create(:event) }

  describe "POST #create" do
    it "allows a confirmed user to comment" do
      user = FactoryBot.create(:user)
      sign_in user

      expect {
        post :create, params: { event_id: event.id, comment: { body: "Hello" } }
      }.to change(Comment, :count).by(1)

      expect(response).to redirect_to(event_path(event))
    end

    it "blocks an unconfirmed user from commenting" do
      user = FactoryBot.create(:user, :unconfirmed)
      sign_in user

      expect {
        post :create, params: { event_id: event.id, comment: { body: "Hello" } }
      }.not_to change(Comment, :count)

      expect(response).to redirect_to(event_path(event))
      expect(flash[:alert]).to eq(I18n.t("comment.rejection.unconfirmed"))
    end

    it "allows a guest with guest_guid to comment without email confirmation" do
      guest = FactoryBot.create(:guest)
      FactoryBot.create(:attendance, event: event, attendee: guest)

      expect {
        post :create, params: {
          event_id: event.id,
          guest_guid: guest.guid,
          comment: { body: "Guest hello" },
        }
      }.to change(Comment, :count).by(1)

      expect(response).to redirect_to(event_path(event, guest_guid: guest.guid))
    end
  end

  describe "DELETE #destroy" do
    it "allows an unconfirmed host to soft-delete a comment on their event" do
      host = FactoryBot.create(:user, :unconfirmed)
      event = FactoryBot.create(:event, owner: host)
      comment = FactoryBot.create(:comment, event: event)
      sign_in host

      delete :destroy, params: { id: comment.id }

      expect(comment.reload.deleted_at).to be_present
      expect(response).to redirect_to(event_path(event))
    end
  end
end
