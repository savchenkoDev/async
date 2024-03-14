module Producers
  module Audits
    class CreatedV1 < BaseProducer
      private

      def topic_name
        'audits-stream'
      end

      def build_registry
        SchemaRegistry.validate_event(event, 'audit.created', version: 1)
      end

      def specific_payload
        {
          event_version: 1,
          registry: 'audit.created',
          event_name: 'AuditCreated',
          data: @object.to_h
        }
      end
    end
  end
end
