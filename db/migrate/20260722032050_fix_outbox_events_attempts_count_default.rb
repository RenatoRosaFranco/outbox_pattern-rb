# frozen_string_literal: true

class FixOutboxEventsAttemptsCountDefault < ActiveRecord::Migration[8.1]
  def up
    execute <<~SQL.squish
      UPDATE outbox_events
      SET attempts_count = 0
      WHERE attempts_count IS NULL
    SQL

    change_column_null :outbox_events, :attempts_count, false
    change_column_default :outbox_events, :attempts_count, 0
  end

  def down
    change_column_null :outbox_events, :attempts_count, true
    change_column_default :outbox_events, :attempts_count, nil
  end
end
