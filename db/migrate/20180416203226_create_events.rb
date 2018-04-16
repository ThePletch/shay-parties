class CreateEvents < ActiveRecord::Migration[5.2]
  def change
    create_table :events do |t|
      t.string :title
      t.timestamp :start_time
      t.timestamp :end_time
      t.text :description

      t.timestamps
    end
  end
end
