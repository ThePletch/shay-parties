class RemoveDefaultHostFromUser < ActiveRecord::Migration[6.0]
  def change
    remove_column :users, :default_host, :string
  end
end
