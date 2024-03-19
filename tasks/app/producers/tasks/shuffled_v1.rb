module Producers
  module Tasks
    class ShuffledV1 < BaseProducer
      private

      def topic_name
        'tasks'
      end

      def build_registry
        SchemaRegistry.validate_event(event, 'task.shuffled', version: 1)
      end

      def specific_payload
        {
          event_version: 1,
          registry: 'task.shuffled',
          event_name: 'TaskShuffled',
          data: {
            public_id: task.public_id,
            old_user_id: old_user_id,
            new_user_id: task.user.public_id
          }
        }
      end
    end
  end
end
