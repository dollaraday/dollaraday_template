class MergeDonorAndRecurringDonor < ActiveRecord::Migration
  def up
    change_table :donors do |t|
      # Simplifying the models, since they're all recurring right now
      t.remove :type
      t.remove :gift_recipient_name
      t.remove :gift_recipient_email

      # Rearrange cols too
      t.change :updated_at, :datetime, after: :uncancelled_at
      t.change :created_at, :datetime, after: :uncancelled_at
      t.change :cancelled_at, :datetime, after: :subscriber_id
      t.change :finished_on, :date, after: :subscriber_id
      t.change :started_on, :date, after: :subscriber_id
      t.change :subscriber_id, :integer, after: :id
      t.change :guid, :string, after: :id
    end

    change_table :newsletters do |t|
      # Merging Donor + RecurringDonor
      t.rename :recurring_generated, :donor_generated
      t.rename :recurrings_sent_at, :donors_sent_at

      # Rearrange cols too
      t.change :donor_generated, :text, after: :nonprofit_id
      t.change :donors_sent_at, :datetime, after: :donor_generated
      t.change :subscriber_generated, :text, after: :donor_generated
      t.change :subscribers_sent_at, :datetime, after: :donors_sent_at
    end
  end

  def down
    change_table :donors do |t|
      t.add :type, :string, after: :nfg_donor_token
      t.add :gift_recipient_email, after: :email
      t.add :gift_recipient_name, after: :gift_recipient_email
    end

    change_table :newsletters do |t|
      t.rename :donor_generated, :recurring_generated
      t.rename :donors_sent_at, :recurrings_sent_at
    end
  end
end

