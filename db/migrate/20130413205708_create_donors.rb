class CreateDonors < ActiveRecord::Migration
  def change
    create_table :donors do |t|
      t.integer :user_id
      t.string :nfg_donor_token
      t.string :nfg_cof_id
      t.string :ip_address
      t.string :name
      t.string :email
      t.boolean :is_recurring # monthly
      t.date :started_on
      t.date :finished_on
      t.timestamps
    end
  end
end
