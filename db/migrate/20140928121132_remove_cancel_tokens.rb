class RemoveCancelTokens < ActiveRecord::Migration
  def change
    change_table :donors do |t|
      t.remove :cancel_token
      t.remove :uncancel_token
    end
  end
end
