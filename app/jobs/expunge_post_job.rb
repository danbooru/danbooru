# frozen_string_literal: true

# A job that permanently deletes a post.
#
# @see {Post#expunge_later!}
class ExpungePostJob < ApplicationJob
  # Expunges run before everything else, including uploads.
  queue_with_priority(-30)

  # Keep retrying on failure (e.g. storage or network errors). If the post was already expunged by another job, the
  # retry is discarded when the post fails to deserialize.
  retry_on StandardError, wait: :polynomially_longer, attempts: 10

  def job_timeout
    1.hour
  end

  def perform(post:, user:)
    CurrentUser.scoped(user) do
      post.expunge!(user)
    end
  end
end
