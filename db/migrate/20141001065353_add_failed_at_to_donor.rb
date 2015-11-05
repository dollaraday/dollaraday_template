class AddFailedAtToDonor < ActiveRecord::Migration
  def change
    change_table :donors do |t|
      t.datetime :failed_at, after: :finished_on
    end
  end
end
