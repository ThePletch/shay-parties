class AddSecretToEvents < ActiveRecord::Migration[6.0]
  def change
    add_column :events, :secret, :bool, default: false
  end
end
