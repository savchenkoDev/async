module Producers
  module Accounts
    class CreatedV1 < BaseProducer
      private

      def topic_name
        'users-stream'
      end

      def build_registry
        SchemaRegistry.validate_event(event, 'account.created', version: 1)
      end

      def specific_payload
        {
          event_version: 1,
          registry: 'account.created',
          event_name: 'AccountCreated',
          data: @object.to_h
        }
      end
    end
  end
end
