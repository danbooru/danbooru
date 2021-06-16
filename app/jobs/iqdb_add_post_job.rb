class IqdbAddPostJob < ApplicationJob
  def perform(post)
    IqdbClient.new.add_post(post)
  end
end
