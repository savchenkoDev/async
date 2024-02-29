class Producer
  def self.call(...)
    new(...).call
  end

  def initialize(payload, topic:)
    @payload = payload,
    @topic = topic
  end

  def call
  
  end
end