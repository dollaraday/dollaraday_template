class CreateEmails < ActiveRecord::Migration
  def change
    create_table :emails do |t|
      t.integer :newsletter_id
      t.integer :donor_id
      t.integer :subscriber_id
      t.datetime :sent_at

      t.timestamps
    end
  end
end
