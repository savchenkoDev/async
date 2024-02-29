class User < ApplicationRecord
  devise :database_authenticatable, :registerable

  has_many :sessions, class_name: 'UserSession', dependent: :destroy

  enum :role, {
    admin: 'admin',
    manager: 'manager',
    popug: 'popug',
    accountant: 'accountant'
  }
end
