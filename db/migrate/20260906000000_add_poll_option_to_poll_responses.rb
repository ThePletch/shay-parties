# frozen_string_literal: true

class AddPollOptionToPollResponses < ActiveRecord::Migration[7.2]
  def change
    add_reference :poll_responses, :poll_option, foreign_key: true
  end
end
