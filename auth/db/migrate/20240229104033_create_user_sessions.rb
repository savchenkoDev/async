class CreateUserSessions < ActiveRecord::Migration[7.0]
  def change
    enable_extension 'pgcrypto'
    create_table :user_sessions, id: :uuid do |t|
      t.uuid :user_id
      t.timestamps

      t.index :user_id
    end
  end
end
