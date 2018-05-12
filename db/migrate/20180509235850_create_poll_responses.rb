class CreatePollResponses < ActiveRecord::Migration[5.2]
  def change
    create_table :poll_responses do |t|
      t.references :poll
      t.references :user
      t.string :choice
      t.boolean :example_response

      t.timestamps
    end
  end
end
