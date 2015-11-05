class AddDonorCard < ActiveRecord::Migration
  def up
  	create_table :donor_cards do |t|
  		t.integer  :donor_id
    	t.string   :nfg_cof_id
    	t.boolean  :is_active
    	t.string   :name
    	t.timestamps
  	end

  	add_column :donations, :donor_card_id, :integer

  	Donation.reset_column_information
  	DonorCard.reset_column_information

  	Donor.all.each do |donor|
  		donor.create_card!(
  			skip_create_cof: true,
  			name: donor.name,
  			nfg_cof_id: donor.nfg_cof_id,
  			is_active: true,
  			donor: donor
  		)
  		donor.donations.each do |d|
  			d.update_column(:donor_card_id, donor.card.id)
  		end
  	end

  	remove_column :donors, :name
  	remove_column :donors, :nfg_cof_id
  end

  def down
		raise IrreversibleMigration
  end
end
