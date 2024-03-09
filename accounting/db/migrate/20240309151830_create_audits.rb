class CreateAudits < ActiveRecord::Migration[7.0]
  def change
    create_table :audits do |t|
      t.string :type
      t.decimal :amount
      t.uuid :task_id

      t.timestamps
    end
  end
end
