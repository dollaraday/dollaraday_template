class AddAttachmentPhotoToCharities < ActiveRecord::Migration
  def self.up
    change_table :charities do |t|
      t.attachment :photo
    end
  end

  def self.down
    drop_attached_file :charities, :photo
  end
end
