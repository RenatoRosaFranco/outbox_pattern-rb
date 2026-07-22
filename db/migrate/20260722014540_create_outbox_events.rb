# frozen_string_literal: true

class CreateOutboxEvents < ActiveRecord::Migration[8.1]
  def change
    create_table :outbox_events do |t|
      t.string :aggregate_type, null: false
      t.uuid :aggregate_id, null: false
      t.string :event_type, null: false
      t.jsonb :payload, null: false, default: {}
      t.string :status, null: false, default: 'pending'
      t.integer :attempts_count, null: false, default: 0
      t.datetime :published_at
      t.text :last_error

      t.timestamps
    end

    add_index :outbox_events, [ :status, :created_at ]
    add_index :outbox_events, [ :aggregate_type, :aggregate_id ]
  end
end
