class CreateMailingListEmails < ActiveRecord::Migration[5.2]
  def change
    create_table :mailing_list_emails do |t|
      t.references :mailing_list, null: false
      t.references :user
      t.string :email
    end
  end
end
