class MigrateAddressAssocsToEvents < ActiveRecord::Migration[5.2]
  def change
    Address.all.each do |address|
        address.event.update(address_id: address.id)
    end
  end
end
