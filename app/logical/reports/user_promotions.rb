module Reports
  class UserPromotions
    def self.deletion_confidence_interval_for(user, days = nil)
      date = (days || 60).days.ago
      deletions = Post.where("created_at >= ?", date).where(:uploader_id => user.id, :is_deleted => true).count
      total = Post.where("created_at >= ?", date).where(:uploader_id => user.id).count
      DanbooruMath.ci_lower_bound(deletions, total)
    end
  end
end
