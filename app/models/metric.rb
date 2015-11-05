class Metric < ActiveRecord::Base
  validates :key, :value, presence: true
end
