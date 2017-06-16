class KeyValue < ApplicationRecord
  validates_uniqueness_of :key
  attr_accessible :key, :value
end
