class MakePollRespondentTypeAlsoNullable < ActiveRecord::Migration[6.0]
  def change
    change_column :poll_responses, :respondent_type, :string, null: true
  end
end
