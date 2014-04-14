class KeyValue < ActiveRecord::Base
  validates_uniqueness_of :key
  attr_accessible :key, :value
end
