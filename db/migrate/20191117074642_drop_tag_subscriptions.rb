require_relative "20100307073438_create_tag_subscriptions"

class DropTagSubscriptions < ActiveRecord::Migration[6.0]
  def change
    revert CreateTagSubscriptions
  end
end
