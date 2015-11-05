class BackfillDonorCardEmail < ActiveRecord::Migration
  def up
    # The last migration added DonorCard#email. But all cards before that would
    # be blank. We'll backfill them so they're valid records, and their audits
    # will indicate that we backfilled them in this migration.
    DonorCard.where(email: nil).each do |dc|
      puts "Backfilling email for DonorCard ##{dc.id}..."
      # Fetch the live COF email and otherwise fallback to the subscriber email.
      cofs = NetworkForGood::CreditCard.get_donor_co_fs(dc.donor)[:cards]
      cof = cofs.present? ? Array.wrap(cofs[:cof_record]).find { |c| c[:cof_id] == dc.nfg_cof_id } : nil
      email = cof.present? ? cof[:cof_email_address] : dc.donor.subscriber.email

      dc.update_attribute(:email, email)
    end
  end

  def down
    raise IrreversibleMigration
  end
end
