class DailyMaintenance
  def run
    ActiveRecord::Base.connection.execute("set statement_timeout = 0")
    PostPruner.new.prune!
    TagPruner.new.prune!
    Upload.delete_all(['created_at < ?', 1.day.ago])
    ModAction.delete_all(['created_at < ?', 3.days.ago])
    Delayed::Job.delete_all(['created_at < ?'], 1.day.ago)
    PostVote.delete_all(['created_at < ?', 1.month.ago])
    TagSubscription.process_all
    prune_ad_hits
  end
  
  def prune_ad_hits
    AdvertisementHit.delete_all(["created_at < ?", 1.month.ago])
  end
end
