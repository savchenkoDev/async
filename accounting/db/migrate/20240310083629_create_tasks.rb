class CreateTasks < ActiveRecord::Migration[7.0]
  def change
    create_table :tasks do |t|
      t.references :user
      t.uuid "public_id"
      t.string "title"
      t.string "description"
      t.decimal "assign_cost"
      t.decimal "finish_cost"
      t.string "status", default: "opened", null: false

      t.timestamps
    end
  end
end
