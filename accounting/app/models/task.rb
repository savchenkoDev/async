class Task < ApplicationRecord
  validate :validate_title
  enum :status, { opened: 'opened', finished: 'finished' }

  private

  def validate_title
    return unless title.match?(/[\[\]]/)

    errors.add(:title, 'contains jira_id')
  end
end
