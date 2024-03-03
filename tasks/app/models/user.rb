class User < ApplicationRecord
  enum :role, {
    admin: 'admin',
    accountant: 'accountant',
    popug: 'popug',
    manager: 'manager'
  }
end
