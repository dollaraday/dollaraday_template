class RearrangeDonationNonprofitColumns < ActiveRecord::Migration
  def change
    change_table "donation_nonprofits" do |t|
      t.change :donation_on, :date, after: :nonprofit_id
    end
  end
end
