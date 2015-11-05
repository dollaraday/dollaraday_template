class AddOriginalMonthsRemainingToGifts < ActiveRecord::Migration
  def change
    change_table :gifts do |t|
      t.integer :original_months_remaining, after: :message
    end
  end
end
