class CreatePayments < ActiveRecord::Migration[8.1]
  def change
    create_table :payments do |t|
      t.string :account_id
      t.integer :amount_cents
      t.string :currency
      t.string :status
      t.string :idempotency_key

      t.timestamps
    end
  end
end
