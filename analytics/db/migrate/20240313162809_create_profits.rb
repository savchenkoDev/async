class CreateProfits < ActiveRecord::Migration[7.0]
  def change
    create_table :profits do |t|
      t.decimal :amount
      t.date :date
    end
  end
end
