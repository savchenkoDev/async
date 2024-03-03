class UsersConsumer < ApplicationConsumer
  def consume
    messages.each do |message|
      case message.payload['event_name']
      when 'UserCreated'
        user_data = parse_user_data(message.payload['data'])
        User.create(user_data)
      when 'UserChanged'
        user_data = parse_user_data(message.payload['data'])
        User.find_by(public_id: user_data[:public_id]).update(user_data.except(:public_id))
      when 'UserDeleted'
        user_data = parse_user_data(message.payload['data'])
        User.find_by(public_id: user_data[:public_id]).destroy
      when 'UserRoleUpdated'
      else
        puts "Unknown Event: #{message.payload['event_name']}"
      end
    end
  end

  private

  def parse_user_data(data)
    user_data = JSON.parse(data)
    user_data['public_id'] = user_data.delete('id')
    user_data.with_indifferent_access
  end
end