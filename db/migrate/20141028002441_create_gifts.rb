class CreateGifts < ActiveRecord::Migration
  def change
    create_table :gifts do |t|
      t.string :giver_email
      t.string :message
      t.integer :months_remaining
      t.date :started_on
      t.timestamps
    end

    change_table :donors do |t|
      t.integer :gift_id, after: :subscriber_id
    end
  end
end
