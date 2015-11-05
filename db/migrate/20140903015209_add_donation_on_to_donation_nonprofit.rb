class AddDonationOnToDonationNonprofit < ActiveRecord::Migration
  def change
    change_table :donation_nonprofits do |t|
      t.date :donation_on
    end
  end
end
