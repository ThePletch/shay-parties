class MakeAddressesUnique < ActiveRecord::Migration[5.2]
  def change
    previously_seen_addresses = []
    Address.all.each do |address|
      if already_seen = previously_seen_addresses.find(address)
        # update any events referencing this address to the earliest instance of it
        Event.where(address: address).update_all(address_id: already_seen.id)
        address.destroy!
        next
      end

      previously_seen_addresses << address
    end
  end
end
