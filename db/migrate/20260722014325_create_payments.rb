# frozen_string_literal: true

class CreatePayments < ActiveRecord::Migration[8.1]
  def change
    create_table :payments do |t|
      t.string :account_id, null: false
      t.integer :amount_cents, null: false
      t.string :currency, null: false, limit: 3
      t.string :status, null: false, default: 'pending'
      t.string :idempotency_key, null: false

      t.timestamps
    end

    add_index :payments, :idempotency_key, unique: true

    add_check_constraint(
      :payments,
      "amount_cents > 0",
      name: "payments_amount_cents_positive"
    )
  end
end
