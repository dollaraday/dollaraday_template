class Favorite < ActiveRecord::Base
  belongs_to :subscriber
  belongs_to :nonprofit
  validates_uniqueness_of :subscriber_id, :scope => [:nonprofit_id]
  audited
end
