class SplitNewsletterSentAtIntoTwoFields < ActiveRecord::Migration
  def up
    add_column :newsletters, :donors_sent_at, :datetime
    add_column :newsletters, :subscribers_sent_at, :datetime
    remove_column :newsletters, :sent_at
  end

  def down
    add_column :newsletters, :sent_at, :datetime
    rmeove_column :newsletters, :donors_sent_at, :datetime
    rmeove_column :newsletters, :subscribers_sent_at, :datetime
  end
end
