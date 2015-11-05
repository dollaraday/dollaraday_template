class RearrangeEmailColumns < ActiveRecord::Migration
  def change
    change_table "emails" do |t|
      t.change :mailer, :string, after: :subscriber_id
      t.change :mailer_method, :string, after: :mailer
    end
  end
end
