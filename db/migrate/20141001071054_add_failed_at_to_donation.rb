class AddFailedAtToDonation < ActiveRecord::Migration
  def change
    change_table :donations do |t|
      t.datetime :failed_at, after: :locked_at
      t.string :last_failure, after: :added_fee
    end
  end
end
