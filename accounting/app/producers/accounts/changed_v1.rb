module Producers
  module Accounts
    class ChangedV1 < BaseProducer
      private

      def topic_name
        'users-stream'
      end

      def build_registry
        SchemaRegistry.validate_event(event, 'account.changed', version: @version)
      end

      def specific_payload
        {
          event_version: 1,
          registry: 'account.changed',
          event_name: 'AccountChanged',
          data: @object.to_h
        }
      end
    end
  end
end
