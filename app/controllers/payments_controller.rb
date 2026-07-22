# frozen_string_literal: true

class PaymentsController < ApplicationController
  def create
    payment = Payments::Create.call(
      attributes: payment_params.to_h,
      idempotency_key: request.headers["Idempotency-Key"]
    )

    render json: {
      id: payment.id,
      account_id: payment.account_id,
      amount_cents: payment.amount_cents,
      currency: payment.currency,
      status: payment.status
    }, status: :created
  rescue Payments::Create::MissingIdempotencyKey => error
    render json: {
      error: error.message
    }, status: :unprocessable_entity
  rescue ActiveRecord::RecordInvalid => error
    render json: {
      error: "validation_error",
      details: error.record.errors.to_hash
    }, status: :unprocessable_entity
  end

  private

  def payment_params
    params.require(:payment).permit(
      :account_id,
      :amount_cents,
      :currency
    )
  end
end
