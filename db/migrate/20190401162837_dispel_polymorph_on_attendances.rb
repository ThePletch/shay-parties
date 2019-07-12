class DispelPolymorphOnAttendances < ActiveRecord::Migration[5.2]
  def change
    # drop column-coupled indexes
    remove_index :attendances, name: :index_attendances_on_attendable_type_and_attendable_id
    remove_index :attendances, name: :index_attendances_on_invitable_type_and_invitable_id

    # delete polymorphic type columns
    remove_column :attendances, :attendable_type
    remove_column :attendances, :invitable_type

    # rename polymorphic reference columns to direct references
    rename_column :attendances, :attendable_id, :event_id
    rename_column :attendances, :invitable_id, :user_id

    # add foreign keys + indexes to new columns
    change_column :attendances, :event_id, :integer, foreign_key: :event
    change_column :attendances, :user_id, :integer, foreign_key: :user
  end
end
