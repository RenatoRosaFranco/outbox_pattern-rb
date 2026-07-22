# frozen_string_literal: true

class Payment < ApplicationRecord
  # Enums
  enum :status, {
    pending: "pending",
    approved: "approved",
    rejected: "rejected"
  }, default: :pending, validate: true

  #  # TODO: extract this to a validation class (Validator)
  # Validations
  validates :account_id, presence: true
  validates :amount_cents, numericality: {
    only_integer: true,
    greater_than: 0
  }

  validates :currency, presence: true,
                       length: { is: 3 }

  validates :idempotency_key, presence: true,
                              uniqueness: true
end
