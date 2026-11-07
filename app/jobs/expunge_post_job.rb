# frozen_string_literal: true

# A job that permanently deletes a post.
#
# @see {Post#expunge_later!}
class ExpungePostJob < ApplicationJob
  def perform(post:, user:)
    post.expunge!(user)
  end
end
