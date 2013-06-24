require 'statistics2'

module Reports
  class UserPromotions
    def self.confidence_interval_for(user, n)
      up_votes = Post.where("created_at >= ?", min_time).where(:uploader_id => user.id).where("fav_count >= ?", n).count
      total_votes = Post.where("created_at >= ?", min_time).where(:uploader_id => user.id).count
      ci_lower_bound(up_votes, total_votes, 0.95)
    end

    def self.ci_lower_bound(pos, n, confidence)
      if n == 0
        return 0
      end

      z = Statistics2.pnormaldist(1-(1-confidence)/2)
      phat = 1.0*pos/n
      100 * (phat + z*z/(2*n) - z * Math.sqrt((phat*(1-phat)+z*z/(4*n))/n))/(1+z*z/n)
    end

    def self.min_time
      30.days.ago
    end

    def users
      User.with_timeout(30_000) do
        User.joins(:posts).where("users.level < ? and users.post_upload_count >= 100", User::Levels::CONTRIBUTOR).where("posts.created_at >= ? and posts.fav_count >= 1", self.class.min_time).order("users.id").select("distinct users.id")
      end
    end
  end
end
