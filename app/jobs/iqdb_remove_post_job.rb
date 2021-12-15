# frozen_string_literal: true

# A job that removes a post from IQDB when it is deleted. Spawned by the {Post}
# class.
class IqdbRemovePostJob < ApplicationJob
  def perform(post_id)
    IqdbClient.new.remove(post_id)
  end
end
