class AddFieldsToCharity < ActiveRecord::Migration
  def change
    change_table :charities do |t|
      t.string :url, after: :description
      t.string :slug, after: :url
    end
  end
end
