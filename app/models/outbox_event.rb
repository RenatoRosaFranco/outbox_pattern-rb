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

  # Methods
  # TODO: extract this to a interface
  def mark_as_published!
    update!(
      status: :published,
      published_at: Time.current,
      last_error: nil,
    )
  end

  def register_failure!(error)
    update!(
      attempts_count: attempts_count.to_i + 1,
      last_error: "#{error.class}: #{error.message}"
    )
  end
end
