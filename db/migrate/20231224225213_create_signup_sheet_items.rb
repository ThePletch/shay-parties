class CreateSignupSheetItems < ActiveRecord::Migration[7.0]
  def change
    create_table :signup_sheet_items do |t|
      t.references :event, foreign_key: true
      t.references :attendee, polymorphic: true
      t.string :description

      t.timestamps
    end
  end
end
