class CreateOutboxEvents < ActiveRecord::Migration[8.1]
  def change
    create_table :outbox_events do |t|
      t.string :aggregate_type
      t.uuid :aggregate_id
      t.string :event_type
      t.jsonb :payload
      t.string :status
      t.integer :attempts_count
      t.datetime :published_at
      t.text :last_error

      t.timestamps
    end
  end
end
