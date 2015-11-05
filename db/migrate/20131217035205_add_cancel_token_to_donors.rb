class AddCancelTokenToDonors < ActiveRecord::Migration
  def change
    change_table(:donors) do |t|
      t.string :cancel_token, after: :guid
    end
  end
end
