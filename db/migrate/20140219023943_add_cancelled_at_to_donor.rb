class AddCancelledAtToDonor < ActiveRecord::Migration
  def change
    change_table(:donors) do |t|
      t.datetime :cancelled_at, after: :finished_on
    end
  end
end

