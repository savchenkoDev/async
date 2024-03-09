class CreateUserSessions < ActiveRecord::Migration[7.0]
  def change
    enable_extension 'pgcrypto'
    create_table :user_sessions, id: :uuid do |t|
      t.references :user
      t.timestamps
    end
  end
end
