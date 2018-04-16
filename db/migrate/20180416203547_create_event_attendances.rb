class CreateEventAttendances < ActiveRecord::Migration
  def self.up
    create_table :event_attendances do |t|

      t.references :attendable, polymorphic: true
      t.references :invitable, polymorphic: true
      t.string :invitation_token
      t.string :invitation_key
      t.string :rsvp_status

      t.timestamps
      
    end
  end

  def self.down
    drop_table :event_attendances
  end
end