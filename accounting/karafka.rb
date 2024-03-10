# frozen_string_literal: true

class KarafkaApp < Karafka::App
  setup do |config|
    config.kafka = { 'bootstrap.servers': 'localhost:29092' }
    config.client_id = 'accounting_service'
    config.consumer_persistence = !Rails.env.development?
  end
end

Karafka.monitor.subscribe(Karafka::Instrumentation::LoggerListener.new)


KarafkaApp.consumer_groups.draw do
  topic 'users-stream' do
    consumer UsersConsumer
  end

  topic 'tasks-stream' do
    consumer TasksConsumer
  end

  topic 'tasks-workflow' do
    consumer TasksWorkflowConsumer
  end
end
