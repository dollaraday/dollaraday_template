class SplitGiftsOutOfDonors < ActiveRecord::Migration
  def up
    # TLDR: turning `donors` into an STI table: RecurringDonor and GiftDonor

    change_table :donors do |t|
      t.string :type
    end

    Donation.reset_column_information

    # Convert all active gift Donors into Gifts, and remove the Donor record for it
    Donor.where(is_gift: true).update_all("type = 'GiftDonor'")
    Donor.where(is_gift: false).update_all("type = 'RecurringDonor'")

    # Remove unnecessary columns
    remove_column :donors, :is_gift
    remove_column :donors, :is_recurring
    remove_column :donors, :user_id # meh, don't need this

    rename_column :newsletters, :donor_generated, :recurring_generated
    rename_column :newsletters, :donors_sent_at, :recurrings_sent_at
  end

  def down
    raise IrreversibleMigration
  end
end
