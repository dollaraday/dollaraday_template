class CreateSubscribers < ActiveRecord::Migration
  def change
    create_table :subscribers do |t|
      t.string :email
      t.string :name
      t.integer :donor_id
      t.string :guid
      t.datetime :subscribed_on
      t.datetime :unsubscribed_on
      t.timestamps
    end
  end
end
