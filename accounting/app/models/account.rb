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
end
