class DropCommontator < ActiveRecord::Migration[6.1]
  def change
    drop_table :commontator_comments
    drop_table :commontator_subscriptions
    drop_table :commontator_threads
  end
end
