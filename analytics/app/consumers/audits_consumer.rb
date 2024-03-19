# frozen_string_literal: true

class AuditsConsumer < ApplicationConsumer
  def consume
    messages.each do |message|
      data = message.payload['data']
      if SchemaRegistry.validate_event(event, message['registry'], version: message['event_version']).failure?
        raise InvalidEventError, message
      end
      case message.payload['event_name']
      when 'AuditCreated'
        profit = Profit.find_or_create_by(date: Date.current)
        profit.update(amount: data['amount'].to_d)
      end
    end
  end
end
