require "rails_helper"

RSpec.describe "comments", type: :system do
  it "aligns edit with delete and asks before deleting" do
    event = FactoryBot.create(:event)
    comment = FactoryBot.create(:comment, event: event, creator: event.owner, body: "See you there")
    sign_in event.owner
    visit event_path(event)

    alignment = page.evaluate_script(<<~JS)
      (() => {
        const edit = document.querySelector(".edit-button").getBoundingClientRect();
        const deletion = document.querySelector(".delete-button").getBoundingClientRect();
        return {
          editCenter: edit.top + edit.height / 2,
          deleteCenter: deletion.top + deletion.height / 2,
        };
      })()
    JS
    expect(alignment["deleteCenter"]).to be_within(0.5).of(alignment["editCenter"])

    dismiss_confirm { click_button "Delete" }
    expect(comment.reload.deleted_at).to be_nil

    accept_confirm { click_button "Delete" }
    expect(page).to have_text("[deleted]")
    expect(comment.reload).to be_deleted
  end
end
