module Producers
  module Tasks
    class CreatedV2 < BaseProducer
      private

      def topic_name
        'tasks-stream'
      end

      def build_registry
        SchemaRegistry.validate_event(event, 'task.created', version: 2)
      end

      def specific_payload
        {
          event_version: 2,
          registry: 'task.created',
          event_name: 'TaskCreated',
          data: @object.to_h.merge(jira_id: @object.jira_id)
        }
      end
    end
  end
end
