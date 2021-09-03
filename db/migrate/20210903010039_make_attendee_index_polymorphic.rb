class MakeAttendeeIndexPolymorphic < ActiveRecord::Migration[6.0]
  def change
    remove_index :attendances, [:event_id, :attendee_id]
    add_index :attendances, [:event_id, :attendee_id, :attendee_type], unique: true
  end
end
