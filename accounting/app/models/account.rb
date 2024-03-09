class Account < ApplicationRecord
  has_many :audits
  validates :user_id, uniqueness: true

  def increment!(value)
    self.balance += value
    save!
  end

  def decrement!(value)
    self.balance = balance - value
    save!
  end
end
