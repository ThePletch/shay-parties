class AddEventOwnershipToAddresses < ActiveRecord::Migration[5.2]
  def change
    add_reference :addresses, :event, foreign_key: true
  end
end
