class TasksWorkflowConsumer < ApplicationConsumer
  def consume
    messages.each do |message|
      data = message.payload['data']
      user = User.find_by(public_id: data['user_id'])
      case message.payload['event_name']
      when 'TaskAssigned'
        user.account.decrement!(data['cost'].to_d)
        user.account.audits.create(amount: data['cost'].to_d * -1)
      when 'TaskFinished'
        user.account.increment!(data['cost'].to_d)
        user.account.audits.create(amount: data['cost'].to_d)
      when 'TaskShuffled'
        old_user = User.find_by(public_id: data['old_user_id'])
        old_user.account.increment!(data['cost'].to_d)
        old_user.account.audits.create(amount: data['cost'].to_d)

        new_user = User.find_by(public_id: data['new_user_id'])
        new_useraccount.decrement!(data['cost'].to_d)
        new_useraccount.audits.create(amount: data['cost'].to_d * -1)
      else
        puts "Unknown Event: #{message.payload['event_name']}"
      end
    end
  end
end