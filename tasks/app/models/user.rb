class User < ApplicationRecord
  has_many :tasks
  enum :role, {
    admin: 'admin',
    accountant: 'accountant',
    popug: 'popug',
    manager: 'manager'
  }
end
