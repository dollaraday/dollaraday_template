class AddTwitterHandleToNonprofit < ActiveRecord::Migration
  def change
    change_table :nonprofits do |t|
      t.string :twitter
    end
  end
end
