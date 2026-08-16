# frozen_string_literal: true

class AddInviteSendsAndDeliveryEvents < ActiveRecord::Migration[7.0]
  def change
    add_column :users, :invite_send_restricted_at, :datetime
    add_column :users, :invite_send_restriction_reason, :string
    add_column :users, :bounce_strikes_reset_at, :datetime

    create_table :invite_sends do |t|
      t.references :user, null: false, foreign_key: true
      t.references :event, null: false, foreign_key: true
      t.string :recipient_email, null: false
      t.string :ses_message_id
      t.timestamps
    end

    add_index :invite_sends, [:user_id, :created_at]
    add_index :invite_sends, :ses_message_id

    create_table :email_delivery_events do |t|
      t.references :invite_send, foreign_key: true
      t.references :user, null: false, foreign_key: true
      t.string :recipient_email, null: false
      t.string :event_type, null: false
      t.string :bounce_type
      t.string :ses_message_id
      t.jsonb :raw_payload
      t.timestamps
    end

    add_index :email_delivery_events, [:user_id, :event_type, :bounce_type, :created_at],
      name: "index_email_delivery_events_on_user_strikes"
    add_index :email_delivery_events, [:ses_message_id, :event_type, :recipient_email],
      unique: true,
      where: "ses_message_id IS NOT NULL",
      name: "index_email_delivery_events_dedup"
  end
end
