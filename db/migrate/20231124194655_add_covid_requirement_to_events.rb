class AddCovidRequirementToEvents < ActiveRecord::Migration[7.0]
  def change
    add_column :events, :requires_testing, :boolean, null: false, default: false
  end
end
