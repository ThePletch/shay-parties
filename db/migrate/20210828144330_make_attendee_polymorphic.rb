class MakeAttendeePolymorphic < ActiveRecord::Migration[6.0]
  def change
    rename_column :attendances, :user_id, :attendee_id
    # create new type column for polymorphic association
    add_column :attendances, :attendee_type, :string, null: true
    # backfill existing rows to specify that they point to users
    if Attendance.any?
      Attendance.where(attendee_type: nil).update_all(attendee_type: "User")
    end
    # switch the new column to be un-nullable
    change_column :attendances, :attendee_type, :string, null: false
  end
end
