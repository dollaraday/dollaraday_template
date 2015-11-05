class AddGiverSubscriberIdToGifts < ActiveRecord::Migration
  def change
    change_table :gifts do |t|
      t.integer :giver_subscriber_id, after: :id
    end
  end
end
