class RenameDateColumnsOnGift < ActiveRecord::Migration
  def up
    rename_column :gifts, :started_on, :start_on
    rename_column :gifts, :finishes_on, :finish_on
  end

  def down
    rename_column :gifts, :start_on, :started_on
    rename_column :gifts, :finish_on, :finishes_on
  end
end
