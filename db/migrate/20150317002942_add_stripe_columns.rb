class AddStripeColumns < ActiveRecord::Migration
  def change
    change_table :donors do |t|
      t.string :stripe_customer_id, after: :nfg_donor_token
    end

    change_table :donor_cards do |t|
      t.string :stripe_card_id, after: :nfg_cof_id
    end

    change_table :donations do |t|
      t.string :stripe_charge_id, after: :nfg_charge_id
    end
  end
end
