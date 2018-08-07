class AddNameToMailingLists < ActiveRecord::Migration[5.2]
  def change
    add_column :mailing_lists, :name, :string
  end
end
