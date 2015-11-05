class CreateTransactions < ActiveRecord::Migration
  def change
    create_table :transactions do |t|
      t.integer :donor_id
      t.integer :amount
      t.decimal :amount, :precision => 10, :scale => 2
      t.string :guid
      t.datetime :scheduled_at
      t.datetime :executed_at
      t.string :nfg_charge_id
      t.boolean :locked_at
      t.timestamps
    end
  end
end
