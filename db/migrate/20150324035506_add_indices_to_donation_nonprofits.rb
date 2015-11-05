class AddIndicesToDonationNonprofits < ActiveRecord::Migration
  def change
    change_table :donation_nonprofits do |t|
      t.index [:nonprofit_id, :donation_id]
      t.index [:donation_id, :nonprofit_id]
    end
  end
end
