# frozen_string_literal: true

class CreatePollOptions < ActiveRecord::Migration[7.2]
  def change
    create_table :poll_options do |t|
      t.references :poll, null: false, foreign_key: true
      t.string :choice, null: false
      t.timestamps
    end
  end
end
