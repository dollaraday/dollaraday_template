class AddPublicToNonprofit < ActiveRecord::Migration
  def change
    change_table :nonprofits do |t|
      t.boolean :public, default: false
    end
  end
end
