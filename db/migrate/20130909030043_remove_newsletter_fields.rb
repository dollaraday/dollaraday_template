class RemoveNewsletterFields < ActiveRecord::Migration
  def up
    remove_column :newsletters, :sender_id
     remove_column :newsletters, :blurb
     remove_column :newsletters, :scheduled_on
  end

  def down
    add_column :newsletters, :sender_id, :integer
    add_column :newsletters, :blurb, :string
    add_column :newsletters, :scheduled_on, :date
  end
end
