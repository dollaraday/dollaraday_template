class RenameSubscriberSubscribedOn < ActiveRecord::Migration
  def up
    rename_column :subscribers, :subscribed_on, :subscribed_at
  end

  def down
    rename_column :subscribers, :subscribed_at, :subscribed_on
  end
end
