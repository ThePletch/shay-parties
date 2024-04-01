class AddRequestedToSignupSheetItems < ActiveRecord::Migration[7.0]
  def change
    add_column :signup_sheet_items, :requested, :boolean, default: false
  end
end
