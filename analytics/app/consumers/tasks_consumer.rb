class TasksConsumer < ApplicationConsumer
  def consume
    messages.each do |message|
      data = message.payload['data']

      case message.payload['event_name']
      when 'TaskCreated'
        Task.create(data)
      when 'TaskChanged'
        Task.find_by(public_id: data['public_id']).update(data)
      when 'TaskDeleted'
        Task.find_by(public_id: data['public_id']).destroy
      when 'TaskFinished'
        Task.find_by(public_id: data['public_id']).update(status: 'finished')
      else
        puts "Unknown Event: #{message.payload['event_name']}"
      end
    end
  end
end