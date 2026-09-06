# frozen_string_literal: true

class MoveExamplePollResponsesToPollOptions < ActiveRecord::Migration[7.2]
  def up
    execute(<<~SQL.squish)
      INSERT INTO poll_options (poll_id, choice, created_at, updated_at)
      SELECT poll_id, choice, created_at, updated_at
      FROM poll_responses
      WHERE example_response = TRUE
      ORDER BY id
    SQL

    execute(<<~SQL.squish)
      DELETE FROM poll_responses
      WHERE example_response = TRUE
    SQL
  end

  def down
    execute(<<~SQL.squish)
      INSERT INTO poll_responses (poll_id, choice, example_response, created_at, updated_at)
      SELECT poll_id, choice, TRUE, created_at, updated_at
      FROM poll_options
      ORDER BY id
    SQL

    execute("DELETE FROM poll_options")
  end
end
