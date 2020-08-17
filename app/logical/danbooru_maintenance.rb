module DanbooruMaintenance
  module_function

  def hourly
    safely { Upload.prune! }
    safely { PostPruner.prune! }
    safely { PostAppealForumUpdater.update_forum! }
    safely { regenerate_post_counts! }
  end

  def daily
    safely { Delayed::Job.where('created_at < ?', 45.days.ago).delete_all }
    safely { PostDisapproval.prune! }
    safely { TokenBucket.prune! }
    safely { BulkUpdateRequestPruner.warn_old }
    safely { BulkUpdateRequestPruner.reject_expired }
    safely { Ban.prune! }
    safely { ActiveRecord::Base.connection.execute("vacuum analyze") unless Rails.env.test? }
  end

  def weekly
    safely { TagRelationshipRetirementService.find_and_retire! }
    safely { ApproverPruner.dmail_inactive_approvers! }
  end

  def monthly
    safely { ApproverPruner.prune! }
  end

  def regenerate_post_counts!
    updated_tags = Tag.regenerate_post_counts!
    updated_tags.each do |tag|
      DanbooruLogger.info("Updated tag count", tag.attributes)
    end
  end

  def safely(&block)
    ActiveRecord::Base.connection.execute("set statement_timeout = 0")

    CurrentUser.scoped(User.system, "127.0.0.1") do
      yield
    end
  rescue StandardError => exception
    DanbooruLogger.log(exception)
    raise exception if Rails.env.test?
  end
end
