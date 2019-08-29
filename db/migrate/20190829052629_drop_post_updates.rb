require_relative "20160820003534_create_post_updates"

class DropPostUpdates < ActiveRecord::Migration[6.0]
  def change
    revert CreatePostUpdates
  end
end
