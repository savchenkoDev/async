class CreateUsers < ActiveRecord::Migration[7.0]
  def change
    create_table :users do |t|
      t.uuid :public_id
      t.string :full_name
      t.string :role
      t.string :email
      t.timestamps
    end
  end
end
