module Producers
  module Tasks
    class DeletedV1 < BaseProducer
      private

      def topic_name
        'tasks-stream'
      end

      def build_registry
        SchemaRegistry.validate_event(event, 'task.deleted', version: 1)
      end

      def specific_payload
        {
          event_version: 1,
          registry: 'task.deleted',
          event_name: 'TaskDeleted',
          data: { public_id: @object.public_id }
        }
      end
    end
  end
end
