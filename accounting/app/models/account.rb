class Account < ApplicationRecord
  has_many :audits
  belongs_to :user

  def increment!(value)
    self.balance += value
    save!
  end

  def decrement!(value)
    self.balance = balance - value
    save!
  end

  def to_h
    {
      public_id: public_id,
      balance: balance
    }
  end

  private

  def produce_account
    event = {
      event_id: SecureRandom.uuid,
      event_version: 1,
      event_name: 'AccountCreated',
      event_time: Time.current.to_s,
      producer: 'accounting_service',
      data: self.to_h
    }
    registry = SchemaRegistry.validate_event(event, 'account.created')
    if registry.success?
      Producer.produce_async(topic: 'accounts-stream', payload: event.to_json
    else
      raise 'InvalidEventError'
    end
  end

  def produce_update
    event = {
      event_id: SecureRandom.uuid,
      event_version: 1,
      event_name: 'AccountChanged',
      event_time: Time.current.to_s,
      producer: 'accounting_service',
      data: self.to_h
    }
    registry = SchemaRegistry.validate_event(event, 'account.changed')
    if registry.success?
      Producer.produce_async(topic: 'accounts', payload: event.to_json)
    else
      raise 'InvalidEventError'
    end
  end

  def produce_destroy
    event = {
      event_name: 'AccountDeleted',
      data: { public_id: self.public_id}
    }

    Producer.produce_async(topic: 'accounts-stream', payload: event.to_json)
  end
end
