module Producers
  module Tasks
    class ChangedV1 < BaseProducer
      private

      def topic_name
        'tasks-stream'
      end

      def build_registry
        SchemaRegistry.validate_event(event, 'task.changed', version: 1)
      end

      def specific_payload
        {
          event_version: 1,
          registry: 'task.changed',
          event_name: 'TaskChanged',
          data: @object.to_h.merge(jira_id: @object.jira_id)
        }
      end
    end
  end
end
