class CreateSignupContexts < ActiveRecord::Migration[7.0]
  def change
    create_table :signup_contexts do |t|
      t.boolean :guest_enterable
      t.references :event, foreign_key: true
      t.text :instructions

      t.timestamps
    end
  end
end
