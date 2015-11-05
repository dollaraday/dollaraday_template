class AddUncancelledAtToDonors < ActiveRecord::Migration
  def change
    add_column :donors, :uncancelled_at, :datetime
  end
end
