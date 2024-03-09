class CreateTasks < ActiveRecord::Migration[7.0]
  def change
    create_table :tasks do |t|
      t.uuid :user_id
      t.string :title
      t.string :description
      t.decimal :cost
      t.string :status, null: false, default: 'opened'

      t.timestamps
    end
  end
end
