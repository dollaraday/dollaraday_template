class UpdateDonorCardIpAddressesWithSubscriberIpAddresses < ActiveRecord::Migration
  def up
    DonorCard.where(ip_address: nil).all.each do |c|
      puts "Update DonorCard##{c.id}'s ip_address"
      c.ip_address ||= c.donor.subscriber.ip_address
      c.save(validate: false)
    end
  end

  def down
    raise IrreversibleMigration
  end
end
