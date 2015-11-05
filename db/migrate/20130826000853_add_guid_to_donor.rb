class AddGuidToDonor < ActiveRecord::Migration
  def change
    change_table :donors do |t|
      t.string :guid
    end
  end
end
