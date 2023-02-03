class CreateFinanceObligations < ActiveRecord::Migration[6.1]
  def change
    create_table :finance_obligations do |t|
      t.references :balance, null: false, foreign_key: true
      t.integer :obligation_type
      t.integer :status
      t.date :charge_date
      t.decimal :amount, { precision: 10, scale: 2 }
      t.timestamps
    end
  end
end
