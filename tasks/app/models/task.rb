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
      event_id: SecureRandom.uuid,
      event_version: 1,
      event_name: 'TaskAssigned',
      event_time: Time.current.to_s,
      producer: 'user_service',
      data: {
        user_id: self.user.public_id,
        public_id: self.public_id,
        assign_cost: self.assign_cost,
        finish_cost: self.finish_cost
      }
    }

    registry = SchemaRegistry.validate_event(event, 'task.assigned')
    if registry.success?
      Producer.produce_async(topic: 'tasks-workflow', payload: event.to_json)
    else
      raise 'InvalidEventError'
    end
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
