class AddRefundedAtToDonation < ActiveRecord::Migration
  def change
    change_table :donations do |t|
      t.datetime :refunded_at, after: :disputed_at
    end
  end
end
