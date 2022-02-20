class CreateComments < ActiveRecord::Migration[6.1]
  def change
    create_table :comments do |t|
      t.references :creator, polymorphic: true
      t.references :editor, polymorphic: true, null: true
      t.references :parent, foreign_key: { to_table: :comments }
      t.text :body
      t.timestamp :deleted_at, null: true
      t.timestamps
    end
  end
end
