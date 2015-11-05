class RearrangeDonationColumns < ActiveRecord::Migration
  def change
    change_table "donations" do |t|
      t.change :guid, :string, after: :id
      t.change :nfg_charge_id, :string, after: :donor_id
      t.change :added_fee, :decimal, after: :amount
      t.change :donor_card_id, :integer, after: :donor_id
      t.change :cancelled_at, :datetime
      t.change :locked_at, :datetime, after: :scheduled_at
    end
  end
end
