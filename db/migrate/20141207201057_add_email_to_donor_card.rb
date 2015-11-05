class AddEmailToDonorCard < ActiveRecord::Migration
  def change
    change_table :donor_cards do |t|
      t.string :email, after: :name
    end
  end
end
