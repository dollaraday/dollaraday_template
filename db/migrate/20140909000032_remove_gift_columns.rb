class RemoveGiftColumns < ActiveRecord::Migration
  def up
    remove_column :newsletters, :gift_generated
    remove_column :newsletters, :gifts_sent_at
  end

  def down
    add_column :newsletters, :gift_generated, :text
    add_column :newsletters, :gifts_sent_at, :datetime
  end
end
