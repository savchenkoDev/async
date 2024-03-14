module Producers
  module Tasks
    class AssignedV1 < BaseProducer
      private

      def topic_name
        'tasks'
      end

      def build_registry
        SchemaRegistry.validate_event(event, 'task.assigned', version: 1)
      end

      def specific_payload
        {
          event_version: 1,
          registry: 'task.assigned',
          event_name: 'TaskCreated',
          data: {
            user_id: @object.user.public_id,
            public_id: @object.public_id,
            assign_cost: @object.assign_cost,
            finish_cost: @object.finish_cost
          }
        }
      end
    end
  end
end
