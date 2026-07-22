# frozen_string_literal: true

class EventBus
  class PublishError < StandardError; end

  # Simulates a message broker
  # 0 => never fails
  # 1 => always fails
  # 0.5 = fails 50% of the time
  def self.publish(event)
    failure_rate = ENV.fetch("EVENT_BUS_FAILURE_RATE", 0).to_f

    if rand < failure_rate
      raise PublishError, "Broker unavailable"
    end

    Rails.logger.info(
      {
        message: "event published",
        event_id: event.id,
        event_type: event.event_type,
        payload: event.payload
      }.to_json
    )

    true
  end
end
