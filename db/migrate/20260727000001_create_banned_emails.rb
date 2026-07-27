# frozen_string_literal: true

class CreateBannedEmails < ActiveRecord::Migration[7.2]
  def change
    create_table :banned_emails do |t|
      t.string :email, null: false
      t.string :reason
      t.references :banned_by, foreign_key: { to_table: :users }, null: true
      t.timestamps
    end

    add_index :banned_emails, :email, unique: true
  end
end
