class CreateMetrics < ActiveRecord::Migration
  def change
    create_table :metrics do |t|
      t.string :key
      t.decimal :value
      t.timestamps
    end
  end
end
