class KeyValue < ActiveRecord::Base
  validates_uniqueness_of :key
end
