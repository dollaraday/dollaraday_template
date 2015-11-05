class AddNfgNameToNonprofits < ActiveRecord::Migration
  def change
    change_table :nonprofits do |n|
      n.string :nfg_name, after: :name
    end
  end
end
