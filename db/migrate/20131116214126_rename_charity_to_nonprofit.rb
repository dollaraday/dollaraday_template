class RenameCharityToNonprofit < ActiveRecord::Migration
  def up
    rename_table :charities, :nonprofits

    rename_column :donation_charities, :charity_id, :nonprofit_id
    rename_table :donation_charities, :donation_nonprofits

    rename_column :newsletters, :charity_id, :nonprofit_id
  end

  def down
    rename_table :nonprofits, :charities

    rename_column :donation_nonprofits, :nonprofit_id, :charity_id
    rename_table :donation_nonprofits, :donation_charities

    rename_column :newsletters, :nonprofit_id, :charity_id
  end
end
