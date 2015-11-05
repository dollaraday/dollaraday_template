class AddGiftFieldsToDonor < ActiveRecord::Migration
  def change
    change_table :donors do |t|
      t.string :gift_recipient_email, after: :email
      t.string :gift_recipient_name, after: :email
    end
  end
end
