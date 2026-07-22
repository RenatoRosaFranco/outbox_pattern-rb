# frozen_string_literal: true

class ChangePaymentsIdToUuid < ActiveRecord::Migration[8.1]
  def up
    enable_extension "pgcrypto" unless extension_enabled?("pgcrypto")

    add_column :payments, :uuid_id, :uuid, null: false, default: -> { "gen_random_uuid()" }

    execute "ALTER TABLE payments DROP CONSTRAINT payments_pkey"
    remove_column :payments, :id

    rename_column :payments, :uuid_id, :id
    execute "ALTER TABLE payments ADD PRIMARY KEY (id)"
    change_column_default :payments, :id, -> { "gen_random_uuid()" }
  end

  def down
    add_column :payments, :bigint_id, :bigint

    execute <<~SQL.squish
      CREATE SEQUENCE payments_id_seq;
      UPDATE payments SET bigint_id = nextval('payments_id_seq');
      ALTER TABLE payments ALTER COLUMN bigint_id SET DEFAULT nextval('payments_id_seq');
      ALTER SEQUENCE payments_id_seq OWNED BY payments.bigint_id;
    SQL

    change_column_null :payments, :bigint_id, false
    execute "ALTER TABLE payments DROP CONSTRAINT payments_pkey"
    remove_column :payments, :id

    rename_column :payments, :bigint_id, :id
    execute "ALTER TABLE payments ADD PRIMARY KEY (id)"
  end
end
