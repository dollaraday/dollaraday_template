class RenamePublicToIsPublic < ActiveRecord::Migration
  def up
  	rename_column :nonprofits, :public, :is_public
  end

  def down
  	rename_column :nonprofits, :public, :is_public
  end
end
