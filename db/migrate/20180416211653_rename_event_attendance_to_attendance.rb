class RenameEventAttendanceToAttendance < ActiveRecord::Migration[5.2]
  def change
    rename_table :event_attendances, :attendances
  end
end
