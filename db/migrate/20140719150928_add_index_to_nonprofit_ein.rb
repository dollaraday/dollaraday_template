class AddIndexToNonprofitEin < ActiveRecord::Migration
  def up
    add_index :nonprofits, :ein
    add_index :nonprofits, :slug
  end

  def down
    remove_index :nonprofits, :ein
    remove_index :nonprofits, :slug
  end
end
