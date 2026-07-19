class AddConfirmableToUsers < ActiveRecord::Migration[7.2]
  def up
    change_table :users, bulk: true do |t|
      t.string :confirmation_token
      t.datetime :confirmed_at
      t.datetime :confirmation_sent_at
      t.string :unconfirmed_email
    end
    add_index :users, :confirmation_token, unique: true

    # Existing accounts remain usable without re-confirming.
    execute "UPDATE users SET confirmed_at = created_at WHERE confirmed_at IS NULL"
  end

  def down
    remove_index :users, :confirmation_token
    change_table :users, bulk: true do |t|
      t.remove :confirmation_token, :confirmed_at, :confirmation_sent_at, :unconfirmed_email
    end
  end
end
