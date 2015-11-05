class AddEmailToEmails < ActiveRecord::Migration
  def change
    change_table :emails do |t|
      t.string :to, after: :subscriber_id
    end
  end
end
