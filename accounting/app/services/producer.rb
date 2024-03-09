class Producer
  def self.produce_sync(topic:, payload:)
    new.produce_sync(topic: topic, payload: payload)
  end

  def self.produce_async(topic:, payload:)
    new.produce_async(topic: topic, payload: payload)
  end

  def initialize
    @producer = build_producer
  end

  def produce_sync(payload:, topic:)
    @producer.produce_sync(topic: topic, payload: payload)
  end

  def produce_async(payload:, topic:)
    @producer.produce_async(topic: topic, payload: payload)
  end

  private
  
  def build_producer
    WaterDrop::Producer.new do |config|
      config.deliver = true
      config.kafka = {
        'bootstrap.servers': Settings.kafka.url,
        'request.required.acks': 1
      }
    end
  end
end