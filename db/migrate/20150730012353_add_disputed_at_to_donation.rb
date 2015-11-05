class AddDisputedAtToDonation < ActiveRecord::Migration
  def change
    change_table :donations do |t|
      t.datetime :disputed_at, after: :cancelled_at
    end
  end
end
