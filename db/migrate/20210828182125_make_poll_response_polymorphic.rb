class MakePollResponsePolymorphic < ActiveRecord::Migration[6.0]
  def change
    rename_column :poll_responses, :user_id, :respondent_id
    # create new type column for polymorphic association
    add_column :poll_responses, :respondent_type, :string, null: true
    # backfill existing rows to specify that they point to users
    PollResponse.where(respondent_type: nil).update_all(respondent_type: "User")
    # switch the new column to be un-nullable
    change_column :poll_responses, :respondent_type, :string, null: false
  end
end
