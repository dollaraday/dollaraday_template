class AddColumnsToSubscriber < ActiveRecord::Migration
  def change
    change_table(:subscribers) do |t|
      t.boolean :is_beta, after: :guid
      t.boolean :is_alpha, after: :guid
      t.string  :unsubscribe_token, after: :unsubscribed_on
    end
  end
end
