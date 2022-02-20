class AddEventRefToComments < ActiveRecord::Migration[6.1]
  def change
    add_reference :comments, :event
  end
end
