require_relative "20110815233456_create_amazon_backups"

class DropAmazonBackups < ActiveRecord::Migration[6.0]
  def change
    revert CreateAmazonBackups
  end
end
