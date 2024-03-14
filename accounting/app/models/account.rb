class Account < ApplicationRecord
  has_many :audits
  belongs_to :user

  after_create :produce_account
  after_destroy :produce_destroy
  after_update :produce_update

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
    Producers::Accounts::CreatedV1.produce(object: self)
  end

  def produce_update
    Producers::Accounts::ChangedV1.produce(object: self)
  end

  def produce_destroy
    event = {
      event_name: 'AccountDeleted',
      data: { public_id: self.public_id}
    }

    Producer.produce_async(topic: 'accounts-stream', payload: event.to_json)
  end
end
