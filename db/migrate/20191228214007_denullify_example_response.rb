class DenullifyExampleResponse < ActiveRecord::Migration[6.0]
  def change
  	PollResponse.where(example_response: nil).update_all(example_response: false)
 	change_column :poll_responses, :example_response, :boolean, null: false
  end
end
