class TasksConsumer < ApplicationConsumer
  JIRA_ID_REGEX = /\[.+\]\W+/.freeze

  def consume
    messages.each do |message|
      data = message.payload['data']
      if SchemaRegistry.validate_event(event, message['registry'], version: message['event_version']).failure?
        raise InvalidEventError, message
      end
      case message.payload['event_name']
      when 'TaskCreated'
        case message.payload['event_version']
        when 1
          match = data['title'].match(JIRA_ID_REGEX).to_s
          data['title'] = data['title'].gsub(JIRA_ID_REGEX, '')
          data['jira_id'] = match.to_s.gsub(/\]\W+/, '').delete('[')

          Task.create(data)
        else
          Task.create(data)
        end
      when 'TaskChanged'
        task = Task.find_by(public_id: data['public_id'])
        case message.payload['event_version']
        when 1
          match = data['title'].match(JIRA_ID_REGEX).to_s
          data['title'] = data['title'].gsub(JIRA_ID_REGEX, '')
          data['jira_id'] = match.to_s.gsub(/\]\W+/, '').delete('[')

          task.update(data)
        else
          task.update(data)
        end
      when 'TaskDeleted'
        Task.find_by(public_id: data['public_id']).destroy
      else
        puts "Unknown Event: #{message.payload['event_name']}"
      end
    end
  rescue InvalidEventError => e
    # move message to topic 'users-errors'
  end
end