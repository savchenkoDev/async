class Audit < ApplicationRecord
  self.inheritance_column = :_type

  belongs_to :account

  after_create :produce_event

  private

  def produce_event
    Producers::Audits::CreatedV1.produce(object: self)
  end
end
