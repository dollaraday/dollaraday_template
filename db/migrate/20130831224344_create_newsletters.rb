class CreateNewsletters < ActiveRecord::Migration
  def change
    create_table :newsletters do |t|
      t.integer :sender_id
      t.integer :charity_id
      t.string :blurb
      t.string :generated
      t.date :scheduled_on
      t.datetime :sent_at
      t.timestamps
    end
  end
end
