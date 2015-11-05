class RearrangeUserColumns < ActiveRecord::Migration
  def change
    change_table "users" do |t|
      t.change :created_at, :datetime, after: :last_sign_in_ip
      t.change :updated_at, :datetime, after: :created_at
      t.change :current_sign_in_at, :datetime, after: :last_sign_in_ip
      t.change :last_sign_in_at, :datetime, after: :current_sign_in_at
      t.change :sign_in_count, :integer, default: 0, after: :encrypted_password
      t.change :email, :string, after: :name
    end
  end
end
