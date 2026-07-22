# frozen_string_literal: true

class OutboxPublisherJob < ApplicationJob
  queue_as :outbox


  def perform
    OutboxEvent
      .pending_for_publication
      .limit(batch_size)
      .find_each do |event|
        publish(event)
      end
  end

  private

  def publish(event)
    EventBus.publish(event)

    event.mark_as_published!
  rescue EventBus::PublishError => error
    event.register_failure!(error)

    Rails.logger.error(
      {
        message: "outbox_publish_failed",
        event_id: event.id,
        error: error.message
      }.to_json
    )
  end

  def batch_size
    100
  end
end
