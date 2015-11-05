class CreateFavorites < ActiveRecord::Migration
  def change
    create_table :favorites do |t|
      t.integer :subscriber_id
      t.integer :nonprofit_id
      t.timestamps
    end
  end
end
