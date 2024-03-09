class User < ApplicationRecord
  devise :database_authenticatable, :registerable

  has_many :sessions, class_name: 'UserSession', dependent: :destroy

  enum :role, {
    admin: 'admin',
    manager: 'manager',
    popug: 'popug',
    accountant: 'accountant'
  }

  before_create :assign_public_id

  def to_h
    {
      public_id: self.public_id,
      full_name: self.full_name,
      role: self.role,
      email: self.email
    }
  end

  private

  def assign_public_id
    public_id = SecureRandom.uuid
    while User.exists?(public_id: public_id) do
      public_id = SecureRandom.uuid
    end
    assign_attributes(public_id: public_id)
  end
end
