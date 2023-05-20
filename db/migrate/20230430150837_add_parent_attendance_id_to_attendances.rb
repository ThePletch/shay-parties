class AddParentAttendanceIdToAttendances < ActiveRecord::Migration[6.1]
  def change
    add_reference :attendances, :attendance, foreign_key: :parent_attendance_id, optional: true
  end
end
