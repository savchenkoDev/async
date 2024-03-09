class CreateAudits < ActiveRecord::Migration[7.0]
  def change
    create_table :audits do |t|
      t.references :account
      t.string :type
      t.decimal :amount

      t.timestamps
    end
  end
end
