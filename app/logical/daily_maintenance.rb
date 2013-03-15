class DailyMaintenance
  def run
    PostPruner.new.prune!
    Upload.delete_all(['created_at < ?', 1.day.ago])
    ModAction.delete_all(['created_at < ?', 3.days.ago])
    Delayed::Job.destroy_all(['created_at < ?'], 1.day.ago)
  end
end
