class AccountsConsumer < ApplicationConsumer
  def consume
    messages.each do |message|
      data = message.payload['data']

      case message.payload['event_name']
      when 'AccountCreated'
        Account.create(data)
      when 'AccountDeleted'
        Account.find_by(public_id: data['public_id']).destroy
      when 'AccountBalanceUpdated'
        Account.find_by(public_id: data['public_id']).update(balance: data['balance'])
      else
        puts "Unknown Event: #{message.payload['event_name']}"
      end
    end
  end
end