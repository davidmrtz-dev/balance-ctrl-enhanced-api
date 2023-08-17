class CreateBillingsTransactions < ActiveRecord::Migration[6.1]
  def change
    create_table :billings_transactions do |t|
      t.references :billing, null: false, foreign_key: true
      t.references :transaction, null: false, foreign_key: true

      t.timestamps
    end
  end
end
