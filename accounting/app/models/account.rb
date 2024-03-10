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
      event_name: 'AccountCreated',
      data: self.to_h
    }

    Producer.produce_async(topic: 'accounts-stream', payload: event.to_json)
  end

  def produce_update
     event = {
      event_name: 'AccountBalanceUpdated',
      data: self.to_h
    }

    Producer.produce_async(topic: 'accounts', payload: event.to_json)
  end

  def produce_destroy
    event = {
      event_name: 'AccountDeleted',
      data: self.id
    }

    Producer.produce_async(topic: 'accounts-stream', payload: event.to_json)
  end
end
