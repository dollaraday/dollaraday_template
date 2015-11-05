class AddIpAddressToDonorCards < ActiveRecord::Migration
  def change
    change_table :donor_cards do |t|
      t.string :ip_address, after: :email
    end
  end
end
