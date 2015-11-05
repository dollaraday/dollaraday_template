class RearrangeNonprofitColumns < ActiveRecord::Migration
  def change
    change_table "nonprofits" do |t|
      t.change :is_public, :boolean, default: false, after: :ein
      t.change :created_at, :datetime, after: :logo_updated_at
      t.change :updated_at, :datetime, after: :created_at
    end
  end
end
