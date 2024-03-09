class TasksWorkflowConsumer < ApplicationConsumer
  def consume
    messages.each do |message|
      byebug
      case message.payload['event_name']
      when 'TaskAssigned'
        parsed_data = parse_user_data(message.payload['data'])
        account = Account.find_by(user_id: parsed_data[:user_id])
        account.decrement(parsed_data[:cost])
        account.audits.create(amount: parsed_data[:cost] * -1)
      when 'TaskFinished'
        parsed_data = parse_user_data(message.payload['data'])
        account = Account.find_by(user_id: parsed_data[:user_id])
        account.increment(parsed_data[:cost])
        account.audits.create(amount: parsed_data[:cost])
      when 'TaskShuffled'
        parsed_data = parse_user_data(message.payload['data'])
        old_account = Account.find_by(user_id: parsed_data[:old_user_id])
        old_account.increment(parsed_data[:cost])
        old_account.audits.create(amount: parsed_data[:cost])

        new_account = Account.find_by(user_id: parsed_data[:new_user_id])
        new_account.decrement(parsed_data[:cost])
        new_account.audits.create(amount: parsed_data[:cost] * -1)
      else
        puts "Unknown Event: #{message.payload['event_name']}"
      end
    end
  end

  private
end