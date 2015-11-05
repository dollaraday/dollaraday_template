class AddIsGiftToDonors < ActiveRecord::Migration
  def change
    change_table :donors do |t|
      t.boolean :is_gift, default: false
    end
  end
end
