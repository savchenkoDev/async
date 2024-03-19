module Producers
  module Users
    class DeletedV1 < BaseProducer
      private

      def topic_name
        'users-stream'
      end

      def build_registry
        SchemaRegistry.validate_event(event, 'user.deleted', version: 1)
      end

      def specific_payload
        {
          event_version: 1,
          registry: 'user.deleted',
          event_name: 'UserDeleted',
          data: { public_id: @object.public_id }
        }
      end
    end
  end
end
