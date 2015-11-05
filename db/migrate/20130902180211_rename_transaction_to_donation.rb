class RenameTransactionToDonation < ActiveRecord::Migration
  def up
    rename_table(:transactions, :donations)

    rename_column(:transaction_charities, :transaction_id, :donation_id)
    rename_table(:transaction_charities, :donation_charities)
  end

  def down
    rename_table(:donations, :transactions)

    rename_column(:donation_charities, :donation_id, :transaction_id)
    rename_table(:donation_charities, :transaction_charities)
  end
end
