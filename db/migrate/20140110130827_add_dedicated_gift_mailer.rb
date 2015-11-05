class AddDedicatedGiftMailer < ActiveRecord::Migration
  def change
    change_table :newsletters do |t|
      t.text "gift_generated", after: "donor_generated"
      t.datetime "gifts_sent_at", after: "donors_sent_at"
    end
  end
end
