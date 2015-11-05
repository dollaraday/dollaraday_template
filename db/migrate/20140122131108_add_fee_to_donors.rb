class AddFeeToDonors < ActiveRecord::Migration
  def change
    change_column :donations, :amount, :decimal, default: 0.0, precision: 8, scale: 2

    change_table :donors do |t|
      t.boolean :add_fee, default: false
    end

    change_table :donations do |t|
      t.decimal :added_fee, default: 0.0, precision: 8, scale: 2
    end
  end
end
