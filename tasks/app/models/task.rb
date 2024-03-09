class Task < ApplicationRecord
  validates :title, :description, presence: :true

  before_create :assign_cost
  after_create :assign_user

  enum :status, {
    opened: 'opened',
    finished: 'finished'
  }

  def finish!
    update!(status: 'finished')
  end

  private

  def assign_cost
    self.cost = rand(10..20)
  end

  def assign_user
    update(user_id: User.where(role: 'popug').sample.public_id)
    event = {
      event_name: 'TaskAssigned',
      data: {
        user_id: self.user_id,
        cost: self.cost
      }
    }

    Producer.produce_async(topic: 'tasks-workflow', payload: event.to_json)
  end
end
