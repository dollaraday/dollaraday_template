class AddConvertedToRecipientToGifts < ActiveRecord::Migration
  def change
    change_table :gifts do |t|
      t.boolean :converted_to_recipient, default: false
    end
  end
end
