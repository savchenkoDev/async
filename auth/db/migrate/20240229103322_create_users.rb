class CreateUsers < ActiveRecord::Migration[7.0]
  def change
    enable_extension 'pgcrypto'
    create_table :users, id: :uuid do |t|
      t.string :full_name
      t.string :role, null: false, default: 'popug'
      t.timestamps
    end
  end
end
