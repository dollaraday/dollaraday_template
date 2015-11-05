class AddColumnsToNewsletter < ActiveRecord::Migration
  def up
    add_column :newsletters, :donor_generated, :text
    add_column :newsletters, :subscriber_generated, :text
    remove_column :newsletters, :generated
  end

  def down
    remove_column :newsletters, :donor_generated, :text
    remove_column :newsletters, :subscriber_generated, :text
    add_column :newsletters, :generated, :string # string, woops!
  end
end
