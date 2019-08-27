require_relative "20100215224629_create_advertisements"
require_relative "20100215224635_create_advertisement_hits"

class DropAdvertisements < ActiveRecord::Migration[6.0]
  def change
    revert CreateAdvertisements
    revert CreateAdvertisementHits
  end
end
