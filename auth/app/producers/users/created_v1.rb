module Producers
  module Users
    class CreatedV1 < BaseProducer
      private

      def topic_name
        'users-stream'
      end

      def build_registry
        SchemaRegistry.validate_event(event, 'user.created', version: 1)
      end

      def specific_payload
        {
          event_version: 1,
          registry: 'user.created',
          event_name: 'UserCreated',
          data: @object.to_h
        }
      end
    end
  end
end
