class IqdbRemovePostJob < ApplicationJob
  def perform(post_id)
    IqdbClient.new.remove(post_id)
  end
end
