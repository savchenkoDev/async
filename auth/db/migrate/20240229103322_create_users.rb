class CreateUsers < ActiveRecord::Migration[7.0]
  def change
    create_table :users do |t|
      t.uuid :public_id, null: false
      t.string :full_name
      t.string :role, null: false, default: 'popug'
      t.timestamps
    end

    add_index :users, :public_id, unique: true
  end
end
