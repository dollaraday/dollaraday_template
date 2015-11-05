class FixDonationColumn < ActiveRecord::Migration
  def change
    change_table "donations" do |t|
      t.change :added_fee, :decimal, precision: 8, scale: 2, default: 0.0
    end
  end
end
