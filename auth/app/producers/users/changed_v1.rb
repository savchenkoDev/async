module Producers
  module Users
    class ChangedV1 < BaseProducer
      private

      def topic_name
        'users-stream'
      end

      def build_registry
        SchemaRegistry.validate_event(event, 'user.changed', version: @version)
      end

      def specific_payload
        {
          event_version: 1,
          registry: 'user.changed',
          event_name: 'UserChanged',
          data: @object.to_h
        }
      end
    end
  end
end
