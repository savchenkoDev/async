class UsersConsumer < ApplicationConsumer
  def consume
    messages.each do |message|
      user_data = message.payload['data']

      case message.payload['event_name']
      when 'UserCreated'
        user = User.create(user_data)
        user.create_account
      when 'UserChanged'
        User.find_by(public_id: user_data['public_id']).update(user_data)
      when 'UserDeleted'
        User.find_by(public_id: user_data[:public_id]).destroy
        Account.find_by(public_id: user_data[:public_id]).destroy
      when 'UserRoleUpdated'
      else
        puts "Unknown Event: #{message.payload['event_name']}"
      end
    end
  end
end