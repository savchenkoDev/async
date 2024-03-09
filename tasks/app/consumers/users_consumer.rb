class UsersConsumer < ApplicationConsumer
  def consume
    messages.each do |message|
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
end