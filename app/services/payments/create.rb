# frozen_string_literal: true

# TODO: refactor the hole class to be more clean and readable

module Payments
  class Create
    class MissingIdempotencyKey < StandardError; end

    def self.call(attributes:, idempotency_key:)
      new(
        attributes: attributes,
        idempotency_key: idempotency_key
      ).call
    end

    def initialize(attributes:, idempotency_key:)
      @attributes = attributes.symbolize_keys
      @idempotency_key = idempotency_key.to_s.strip
    end

    def call
      validate_idempotency_key!

      existing_payment = Payment.find_by(
        idempotency_key: idempotency_key
      )

      return existing_payment if existing_payment

      Payment.transaction do
        payment = create_payment!

        create_outbox_event!(payment)

        payment
      end
    rescue ActiveRecord::RecordNotUnique
      Payment.find_by!(
        idempotency_key: idempotency_key
      )
    end

    private

    attr_reader :attributes, :idempotency_key

    def validate_idempotency_key!
      return if idempotency_key.present?

      raise MissingIdempotencyKey, "Idempotency key is required"
    end

    def create_payment!
      Payment.create!(
        attributes.merge(
          idempotency_key: idempotency_key,
          status: :approved
        )
      )
    end

    def create_outbox_event!(payment)
      OutboxEvent.create!(
        aggregate_type: "Payment",
        aggregate_id: payment.id,
        event_type: "payment.created",
        payload: {
          payment_id: payment.id,
          account_id: payment.account_id,
          amount_cents: payment.amount_cents,
          currency: payment.currency,
          status: payment.status,
          occurred_at: Time.current.iso8601
        }
      )
    end
  end
end
