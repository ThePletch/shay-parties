class CreatePolls < ActiveRecord::Migration[5.2]
  def change
    create_table :polls do |t|
      t.string :question
      t.references :event
      t.references :user

      t.timestamps
    end
  end
end
