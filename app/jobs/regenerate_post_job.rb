# frozen_string_literal: true

# A job that regenerates a post's images and IQDB when a moderator requests it.
class RegeneratePostJob < ApplicationJob
  def perform(post:, category:, user:)
    post.regenerate!(category, user)
  end
end
