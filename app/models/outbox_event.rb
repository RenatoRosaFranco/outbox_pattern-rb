# frozen_string_literal: true

class OutboxEvent < ApplicationRecord
  # Enum
  enum :status, {
    pending: "pending",
    published: "published"
  }, default: :pending, validate: true

  # TODO: extract this to a query interface
  # Scopes
  scope :pending_for_publication, -> {
    pending.order(:created_at)
  }

  # TODO: extract this to a validation class (Validator)
  # Validations
  validates :aggregate_type, presence: true
  validates :aggregate_id, presence: true
  validates :event_type, presence: true
  validates :payload, presence: true
end
