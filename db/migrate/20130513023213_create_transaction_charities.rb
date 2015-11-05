class CreateTransactionCharities < ActiveRecord::Migration
  def change
    create_table :transaction_charities do |t|
      t.integer :transaction_id
      t.integer :charity_id
      t.timestamps
    end
  end
end
