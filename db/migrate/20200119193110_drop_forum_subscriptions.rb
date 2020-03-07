require_relative "20140725003232_create_forum_subscriptions"

class DropForumSubscriptions < ActiveRecord::Migration[6.0]
  def change
    revert CreateForumSubscriptions
  end
end
