class MoveIpAddressFromDonorToSubscriber < ActiveRecord::Migration
  def change
    add_column :subscribers, :ip_address, :string

    Subscriber.reset_column_information
    Subscriber.all.each do |s|
      s.update_column :ip_address, s.donor.try(:ip_address) || "127.0.0.1"
    end

    remove_column :donors, :ip_address, :string
  end
end
