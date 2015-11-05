class RenameSubscriberUnsubscribedOn < ActiveRecord::Migration
  def up
    rename_column :subscribers, :unsubscribed_on, :unsubscribed_at
  end

  def down
    rename_column :subscribers, :unsubscribed_at, :unsubscribed_on
  end
end
