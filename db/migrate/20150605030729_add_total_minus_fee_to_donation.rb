class AddTotalMinusFeeToDonation < ActiveRecord::Migration
  def up
		add_column :donations, :total_minus_fee, :decimal, precision: 8, scale: 2, after: :added_fee
		add_column :donations, :total, :decimal, precision: 8, scale: 2, after: :added_fee

  	Donation.reset_column_information

  	Donation.executed.each do |d|
  		d.update_column(:total, d.amount + d.added_fee)
  		d.update_column(:total_minus_fee, d.total - d.calculate_fee)
  	end
  end

  def down
		remove_column :donations, :total_minus_fee
		remove_column :donations, :total
  end
end
