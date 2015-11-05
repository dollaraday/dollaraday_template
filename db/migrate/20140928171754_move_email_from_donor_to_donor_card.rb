class MoveEmailFromDonorToDonorCard < ActiveRecord::Migration
  def change
    change_table :donor_cards do |t|
      t.column :email, :string
    end

    DonorCard.reset_column_information
    DonorCard.all.each { |c| c.update_column(:email, c.donor.email) }

    change_table :donors do |t|
      t.remove :email
    end
  end
end
