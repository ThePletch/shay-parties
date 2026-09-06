# frozen_string_literal: true

class AssignPollResponsesToPollOptions < ActiveRecord::Migration[7.2]
  def up
    execute(<<~SQL.squish)
      UPDATE poll_responses
      SET poll_option_id = matched.id
      FROM (
        SELECT DISTINCT ON (poll_id, choice) id, poll_id, choice
        FROM poll_options
        ORDER BY poll_id, choice, id
      ) AS matched
      WHERE poll_responses.poll_id = matched.poll_id
        AND poll_responses.choice IS NOT DISTINCT FROM matched.choice
    SQL

    execute(<<~SQL.squish)
      DELETE FROM poll_responses
      WHERE poll_option_id IS NULL
    SQL
  end

  def down
    execute(<<~SQL.squish)
      UPDATE poll_responses
      SET poll_id = poll_options.poll_id,
          choice = poll_options.choice
      FROM poll_options
      WHERE poll_options.id = poll_responses.poll_option_id
    SQL
  end
end
