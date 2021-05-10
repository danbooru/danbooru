module BulkUpdateRequestPruner
  module_function

  def warn_old
    BulkUpdateRequest.old.pending.find_each do |bulk_update_request|
      if bulk_update_request.forum_topic
        body = "This bulk update request is pending automatic rejection in 5 days."
        unless bulk_update_request.forum_topic.forum_posts.where(creator_id: User.system.id, body: body).exists?
          bulk_update_request.forum_updater.update(body)
        end
      end
    end
  end

  def reject_expired
    BulkUpdateRequest.expired.pending.find_each do |bulk_update_request|
      ApplicationRecord.transaction do
        if bulk_update_request.forum_topic
          body = "This bulk update request has been rejected because it was not approved within 60 days."
          bulk_update_request.forum_updater.update(body)
        end

        bulk_update_request.reject!(User.system)
      end
    end
  end
end
