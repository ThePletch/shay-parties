class AddIndexesToAttendable < ActiveRecord::Migration[5.2]
  def change
    add_index :attendances, [:event_id, :user_id], unique: true
    add_index :attendances, :event_id
    add_index :attendances, :user_id
  end
end
