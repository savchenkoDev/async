# frozen_string_literal: true

class KarafkaApp < Karafka::App
  setup do |config|
    config.kafka = { 'bootstrap.servers': 'localhost:29092' }
    config.client_id = 'analytics_service'
    # Recreate consumers with each batch. This will allow Rails code reload to work in the
    # development mode. Otherwise Karafka process would not be aware of code changes
    config.consumer_persistence = !Rails.env.development?
  end
end

Karafka.monitor.subscribe(Karafka::Instrumentation::LoggerListener.new)


KarafkaApp.consumer_groups.draw do
  topic 'audits-stream' do
    consumer AuditsConsumer
  end
end
