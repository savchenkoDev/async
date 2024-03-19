module Producers
  module Accounts
    class DeletedV1 < BaseProducer
      private

      def topic_name
        'users-stream'
      end

      def build_registry
        SchemaRegistry.validate_event(event, 'account.deleted', version: 1)
      end

      def specific_payload
        {
          event_version: 1,
          registry: 'account.deleted',
          event_name: 'AccountDeleted',
          data: { public_id: @object.public_id }
        }
      end
    end
  end
end
