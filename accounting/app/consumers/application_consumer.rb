# frozen_string_literal: true

class ApplicationConsumer < Karafka::BaseConsumer
  class InvalidEventError < StandardError; end
end
