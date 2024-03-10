class Task < ApplicationRecord
  belongs_to :user
  validates :title, :description, presence: :true

  before_create :assign_attrs

  enum :status, {
    opened: 'opened',
    finished: 'finished'
  }

  def produce_assign_event
    event = {
      event_name: 'TaskAssigned',
      data: {
        user_id: self.user.public_id,
        public_id: self.public_id,
        assign_cost: self.assign_cost,
        finish_cost: self.finish_cost
      }
    }

    Producer.produce_async(topic: 'tasks-workflow', payload: event.to_json)
  end

  def finish!
    update!(status: 'finished')
  end

  def to_h
    {
      public_id: self.public_id,
      title: self.title,
      description: self.description,
      assign_cost: self.assign_cost.to_f,
      finish_cost: self.finish_cost.to_f
    }
  end

  private

  def assign_attrs
    self.assign_cost = rand(10..20)
    self.finish_cost = rand(20..40)
    self.user_id = User.where(role: 'popug').sample.id
    self.public_id = SecureRandom.uuid
    while Task.exists?(public_id: public_id) do
      self.public_id = SecureRandom.uuid
    end
  end

  
end
