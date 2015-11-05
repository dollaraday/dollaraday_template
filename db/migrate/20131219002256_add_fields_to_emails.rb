class AddFieldsToEmails < ActiveRecord::Migration
  def change
    change_table(:emails) do |t|
      t.string :mailer
      t.string :mailer_method
    end
  end
end
