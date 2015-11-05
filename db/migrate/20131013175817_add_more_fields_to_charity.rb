class AddMoreFieldsToCharity < ActiveRecord::Migration
  def change
    change_table :charities do |t|
      t.string :blurb, after: :description
    end
  end
end
