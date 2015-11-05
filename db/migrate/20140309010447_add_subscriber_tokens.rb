class AddSubscriberTokens < ActiveRecord::Migration
  def up
    add_column :subscribers, :auth_token, :string
    add_index :subscribers, :auth_token, unique: true
  end

  def down
    remove_column :subscribers, :auth_token, :string
    remove_index :subscribers, :auth_token, unique: true
  end
end

