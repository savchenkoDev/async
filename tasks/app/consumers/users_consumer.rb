class UsersConsumer < ApplicationConsumer
  class InvalidEventError < StandardError; end

  def consume
    messages.each do |message|
      if SchemaRegistry.validate_event(event, message['registry'], version: message['event_version']).failure?
        raise InvalidEventError, message
      end
      case message.payload['event_name']
      when 'UserCreated'
        user_data = message.payload['data']
        User.create(user_data.except('id'))
      when 'UserChanged'
        user_data = message.payload['data']
        User.find_by(public_id: user_data['id']).update(user_data.except('id'))
      when 'UserDeleted'
        user_data = message.payload['data']
        User.find_by(public_id: user_data['id']).destroy
      when 'UserRoleUpdated'
      else
        puts "Unknown Event: #{message.payload['event_name']}"
      end
    end
  end
rescue InvalidEventError => error
  # move message to topic 'users-errors'
end