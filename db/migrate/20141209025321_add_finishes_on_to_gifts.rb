class AddFinishesOnToGifts < ActiveRecord::Migration
  def change
    change_table :gifts do |g|
      g.date :finishes_on, after: :started_on
    end
  end
end
