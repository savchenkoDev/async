class CreateTasks < ActiveRecord::Migration[7.0]
  def change
    create_table :tasks do |t|
      t.references :user
      t.uuid :public_id
      t.string :title
      t.string :description
      t.decimal :assign_cost
      t.decimal :finish_cost
      t.string :status, null: false, default: 'opened'

      t.timestamps
    end

    add_index :tasks, :public_id, unique: true
  end
end
