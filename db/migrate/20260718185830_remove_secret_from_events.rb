class RemoveSecretFromEvents < ActiveRecord::Migration[7.1]
  def change
    remove_column :events, :secret, :boolean, default: false
  end
end
