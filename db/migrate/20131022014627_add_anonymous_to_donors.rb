class AddAnonymousToDonors < ActiveRecord::Migration
  def change
    change_table :donors do |t|
      t.boolean :is_anonymous, default: false
    end
  end
end
