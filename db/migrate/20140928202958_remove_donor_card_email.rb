class RemoveDonorCardEmail < ActiveRecord::Migration
  def change
    change_table :donor_cards do |t|
      t.remove :email
    end
  end
end
