# frozen_string_literal: true

class AccountsConsumer < ApplicationConsumer
  def consume
    messages.each do |message|
      data = message.payload['data']
      if SchemaRegistry.validate_event(event, message['registry'], version: message['event_version']).failure?
        raise InvalidEventError, message
      end
      case message.payload['event_name']
      when 'AccountCreated'
        Account.create(data)
      when 'AccountChanged'
        Account.find_by(public_id: data['public_id']).update(data)
      when 'AccountDeleted'
        Account.find_by(public_id: data['public_id']).destroy
      end
    end
  end
end
