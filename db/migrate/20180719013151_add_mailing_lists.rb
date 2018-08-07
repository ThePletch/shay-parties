class AddMailingLists < ActiveRecord::Migration[5.2]
  def change
    create_table :mailing_lists do |t|
      t.references :user

      t.timestamps
    end
  end
end
