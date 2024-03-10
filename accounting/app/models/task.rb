class Task < ApplicationRecord
  enum :status, { opened: 'opened', finished: 'finished' }
end
