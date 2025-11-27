class AddPlusOneCountToEvents < ActiveRecord::Migration[7.1]
  def change
    add_column :events, :plus_one_max, :integer, null: false, default: -1
  end
end
