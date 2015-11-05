class AddFieldsToGifts < ActiveRecord::Migration
  def change
    change_table :gifts do |t|
      t.string :giver_name, after: :giver_email
      t.string :recipient_email, after: :giver_name
      t.string :recipient_name, after: :recipient_email
    end
  end
end
