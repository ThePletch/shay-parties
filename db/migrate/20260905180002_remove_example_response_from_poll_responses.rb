# frozen_string_literal: true

class RemoveExampleResponseFromPollResponses < ActiveRecord::Migration[7.2]
  def up
    remove_column :poll_responses, :example_response
  end

  def down
    add_column :poll_responses, :example_response, :boolean, default: false, null: false
  end
end
