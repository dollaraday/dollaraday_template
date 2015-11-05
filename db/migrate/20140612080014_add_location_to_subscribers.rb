class AddLocationToSubscribers < ActiveRecord::Migration
  def change
    add_column :subscribers, :latitude, :string
    add_column :subscribers, :longitude, :string
    add_column :subscribers, :city, :string
    add_column :subscribers, :region, :string
    add_column :subscribers, :country, :string
  end
end
