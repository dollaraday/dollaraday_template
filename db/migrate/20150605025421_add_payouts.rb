class AddPayouts < ActiveRecord::Migration
  def change
  	create_table :payouts do |t|
  		t.integer :nonprofit_id
  		t.integer :user_id
  		t.decimal :amount, precision: 8, scale: 2
  		t.datetime :payout_at
  		t.timestamps
  	end
  end
end
