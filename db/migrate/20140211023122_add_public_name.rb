class AddPublicName < ActiveRecord::Migration
  def up
    add_column :donors, :public_name, :string
  end

  def down
    remove_column :donors, :public_name
  end
end
