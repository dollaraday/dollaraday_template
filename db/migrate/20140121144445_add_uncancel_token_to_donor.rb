class AddUncancelTokenToDonor < ActiveRecord::Migration
  def change
    change_table :donors do |t|
      t.string :uncancel_token, after: :cancel_token
    end
  end
end
