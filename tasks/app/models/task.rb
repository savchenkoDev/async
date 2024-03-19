class Task < ApplicationRecord
  belongs_to :user
  validates :title, :description, presence: :true
  validates :validate_title

  before_create :assign_attrs

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
      assign_cost: self.assign_cost.to_f,
      finish_cost: self.finish_cost.to_f
    }
  end

  private

  def validate_title
    return unless title.match?(/[\[\]]/)

    errors.add(:title, 'contains jira_id')
  end

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
