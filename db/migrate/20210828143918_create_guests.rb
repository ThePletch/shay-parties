class CreateGuests < ActiveRecord::Migration[6.0]
  def change
    create_table :guests do |t|
      t.string :guid
      t.string :name
      t.string :email

      t.timestamps
    end
  end
end
