class Task < ApplicationRecord
  validates :title, :description, presence: :true

  before_create :assign_cost
  after_create :assign_user

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
      data: self.to_json
    }
    Producer.produce_async(topic: 'tasks', payload: event.to_json)
  end
end
