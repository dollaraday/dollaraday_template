class RearrangeSubscriberColumns < ActiveRecord::Migration
  def change
    change_table "subscribers" do |t|
      # Old unused columns
      t.remove :is_alpha
      t.remove :is_beta
      t.remove :unsubscribe_token

      # Rearrange some columns
      t.change :guid, :string, after: :id
      t.change :ip_address, :string, after: :name
      t.change :latitude, :string, after: :ip_address
      t.change :longitude, :string, after: :latitude
      t.change :city, :string, after: :longitude
      t.change :region, :string, after: :city
      t.change :country, :string, after: :region
      t.change :auth_token, :string, after: :country
    end
  end
end
