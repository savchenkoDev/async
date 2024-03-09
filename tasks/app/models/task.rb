class Task < ApplicationRecord
  belongs_to :user
  validates :title, :description, presence: :true

  before_create :assign_attrs
  after_create :produce_event

  enum :status, {
    opened: 'opened',
    finished: 'finished'
  }

  def finish!
    update!(status: 'finished')
  end

  def to_h
    {
      public_id: self.public_id,
      title: self.title,
      description: self.description,
      cost: self.cost.to_f
    }
  end

  private

  def assign_attrs
    self.cost = rand(10..20)
    self.user_id = User.where(role: 'popug').sample.id
    self.public_id = SecureRandom.uuid
    while Task.exists?(public_id: public_id) do
      self.public_id = SecureRandom.uuid
    end
  end

  def produce_event
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
