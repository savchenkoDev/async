class Audit < ApplicationRecord
  self.inheritance_column = :_type

  belongs_to :account

  after_create :produce_event

  private

  def produce_event
    event = {
      event_name: 'AuditCreated',
      data: self
    }

    Producer.produce_async(topic: 'audits-stream', payload: event.to_json)
  end
end
