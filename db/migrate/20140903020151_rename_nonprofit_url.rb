class RenameNonprofitUrl < ActiveRecord::Migration
  def self.up
    rename_column :nonprofits, :url, :website_url
  end

  def self.down
    rename_column :nonprofits, :website_url, :url
  end
end

