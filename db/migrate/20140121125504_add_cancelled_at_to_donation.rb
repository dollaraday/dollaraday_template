class AddCancelledAtToDonation < ActiveRecord::Migration
  def change
    change_table(:donations) do |t|
      t.string :cancelled_at, after: :executed_at
    end
  end
end
