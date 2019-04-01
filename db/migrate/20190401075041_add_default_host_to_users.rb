class AddDefaultHostToUsers < ActiveRecord::Migration[5.2]
  def change
    add_column :users, :default_host, :boolean, default: false
  end
end
