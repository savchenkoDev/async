module Producers
  module Users
    class RoleChangedV1 < BaseProducer
      private

      def topic_name
        'users'
      end

      def build_registry
        SchemaRegistry.validate_event(event, 'user.changed', version: 1)
      end

      def build_payload
        default_payload,merge(
          event_version: 1,
          registry: 'user.changed',
          event_name: 'UserRoleUpdated',
          data: @user.to_h
        )
      end
    end
  end
end
