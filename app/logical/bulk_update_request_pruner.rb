# frozen_string_literal: true

# Rejects bulk update requests that haven't been approved in 45 days.
module BulkUpdateRequestPruner
  module_function

  # How many days before a bulk update request should be automatically rejected.
  EXPIRATION_PERIOD = 45.days

  # How many days before we should warn about upcoming rejections.
  WARNING_PERIOD = 5.days

  # Posts a warning when a bulk update request is pending automatic rejection in 5 days.
  def warn_old
    upcoming_expired_requests.find_each do |bulk_update_request|
      if bulk_update_request.forum_topic
        body = "This bulk update request is pending automatic rejection in #{WARNING_PERIOD.inspect}."
        unless bulk_update_request.forum_topic.forum_posts.where(creator_id: User.system.id, body: body).exists?
          bulk_update_request.forum_updater.update(body)
        end
      end
    end
  end

  # Rejects bulk update requests that haven't been approved in 45 days.
  def reject_expired
    expired_requests.find_each do |bulk_update_request|
      ApplicationRecord.transaction do
        if bulk_update_request.forum_topic
          body = "This bulk update request has been rejected because it was not approved within #{EXPIRATION_PERIOD.inspect}."
          bulk_update_request.forum_updater.update(body)
        end

        bulk_update_request.reject!(User.system)
      end
    end
  end

  def expired_requests
    BulkUpdateRequest.pending.where("created_at < ?", EXPIRATION_PERIOD.ago)
  end

  def upcoming_expired_requests
    BulkUpdateRequest.pending.where("created_at >= ? and created_at < ?", EXPIRATION_PERIOD.ago, (EXPIRATION_PERIOD - WARNING_PERIOD).ago)
  end
end
