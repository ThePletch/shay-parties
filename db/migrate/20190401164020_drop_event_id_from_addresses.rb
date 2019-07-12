class DropEventIdFromAddresses < ActiveRecord::Migration[5.2]
  def change
    remove_column :addresses, :event_id
  end
end
