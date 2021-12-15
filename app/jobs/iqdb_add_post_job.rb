# frozen_string_literal: true

# A job that adds a post to IQDB when a new post is uploaded, or when a post is
# regenerated. Spawned by the {Post} class.
class IqdbAddPostJob < ApplicationJob
  def perform(post)
    IqdbClient.new.add_post(post)
  end
end
