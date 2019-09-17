# Service to prune old unapproved tag change requests
# (including tag aliases, tag implications, and bulk
# update requests).

class TagChangeRequestPruner
  def self.warn_all
    [TagAlias, TagImplication, BulkUpdateRequest].each do |model|
      new.warn_old(model)
    end
  end

  def self.reject_all
    [TagAlias, TagImplication, BulkUpdateRequest].each do |model|
      new.reject_expired(model)
    end
  end

  def warn_old(model)
    model.old.pending.find_each do |tag_change|
      if tag_change.forum_topic
        name = model.model_name.human.downcase
        body = "This #{name} is pending automatic rejection in 5 days."
        unless tag_change.forum_topic.posts.where(creator_id: User.system.id, body: body).exists?
          tag_change.forum_updater.update(body)
        end
      end
    end
  end

  def reject_expired(model)
    model.expired.pending.find_each do |tag_change|
      ApplicationRecord.transaction do
        if tag_change.forum_topic
          name = model.model_name.human.downcase
          body = "This #{name} has been rejected because it was not approved within 60 days."
          tag_change.forum_updater.update(body)
        end

        CurrentUser.as_system do
          tag_change.reject!
        end
      end
    end
  end
end
