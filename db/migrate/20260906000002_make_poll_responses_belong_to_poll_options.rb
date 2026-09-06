# frozen_string_literal: true

class MakePollResponsesBelongToPollOptions < ActiveRecord::Migration[7.2]
  def up
    change_column_null :poll_responses, :poll_option_id, false
    remove_index :poll_responses, :poll_id
    remove_column :poll_responses, :poll_id
    remove_column :poll_responses, :choice
  end

  def down
    add_reference :poll_responses, :poll, index: true
    add_column :poll_responses, :choice, :string
    change_column_null :poll_responses, :poll_option_id, true
  end
end
