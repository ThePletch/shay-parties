class CreateCohosts < ActiveRecord::Migration[7.0]
  def change
    create_table :cohosts do |t|
      t.references :user, foreign_key: true
      t.references :event, foreign_key: true

      t.timestamps
    end
  end
end
