class ChangeTransactionLockedAtToDatetime < ActiveRecord::Migration
  def up
    change_column(:transactions, :locked_at, :datetime)
  end

  def down
    change_column(:transactions, :locked_at, :boolean)
  end
end
