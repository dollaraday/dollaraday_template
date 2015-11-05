class AddAttachmentLogoToCharities < ActiveRecord::Migration
  def self.up
    change_table :charities do |t|
      t.attachment :logo
    end
  end

  def self.down
    drop_attached_file :charities, :logo
  end
end
