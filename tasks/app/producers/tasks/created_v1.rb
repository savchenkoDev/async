module Producers
  module Tasks
    class CreatedV1 < BaseProducer
      private

      def topic_name
        'tasks-stream'
      end

      def build_registry
        SchemaRegistry.validate_event(event, 'task.created', version: 1)
      end

      def specific_payload
        {
          event_version: 1,
          registry: 'task.created',
          event_name: 'TaskCreated',
          data: @object.to_h
        }
      end
    end
  end
end
