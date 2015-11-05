class RemoveDonorIdFromEmails < ActiveRecord::Migration
  def up
    remove_column :emails, :donor_id
  end

  def down
    add_column :emails, :donor_id, :integer
  end
end
