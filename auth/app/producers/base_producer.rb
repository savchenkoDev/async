class BaseProducer
  class InvalidEventError < StandardError; end

  def self.produce(*args)
    new(*args).produce
  end

  def initialize(object:)
    @object = object
    @producer = build_producer
    @registry = build_registry
    @payload = build_payload
  end

  def produce
    if registry.success?
      @producer.produce_sync(payload: payload.to_json, topic: topic)
    else
      raise InvalidEventError
    end
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

  def topic_name
    raise NotImplementedError
  end

  def build_registry
    raise NotImplementedError
  end

  def specific_payload
    {}
  end

  def build_payload
    {
      event_id: SecureRandom.uuid,
      event_time: Time.current.to_s,
      producer: 'user_service'
    }.merge!(specific_payload)
  end
end
