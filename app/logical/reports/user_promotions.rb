require 'statistics2'

module Reports
  class UserPromotions
    class User
      attr_reader :user
      delegate :name, :post_upload_count, :level_string, :level, :created_at, :upload_limit, :max_upload_limit, :to => :user

      def initialize(user)
        @user = user
      end

      def confidence_interval_for(n)
        Reports::UserPromotions.confidence_interval_for(user, n)
      end

      def deletion_confidence_interval
        Reports::UserPromotions.deletion_confidence_interval_for(user)
      end

      def negative_score_confidence_interval
        Reports::UserPromotions.negative_score_confidence_interval_for(user)
      end

      def median_score
        ActiveRecord::Base.select_value_sql("select percentile_cont(0.50) within group (order by score) from posts where created_at >= ? and uploader_id = ?", ::Reports::UserPromotions.min_time, user.id).to_i
      end

      def quartile_score
        ActiveRecord::Base.select_value_sql("select percentile_cont(0.25) within group (order by score) from posts where created_at >= ? and uploader_id = ?", ::Reports::UserPromotions.min_time, user.id).to_i
      end
    end

    def self.confidence_interval_for(user, n)
      up_votes = Post.where("created_at >= ?", min_time).where(:is_deleted => false, :uploader_id => user.id).where("score >= ?", n).count
      total_votes = Post.where("created_at >= ?", min_time).where(:uploader_id => user.id).count
      ci_lower_bound(up_votes, total_votes)
    end

    def self.deletion_confidence_interval_for(user, days = nil)
      date = (days || 60).days.ago
      deletions = Post.where("created_at >= ?", date).where(:uploader_id => user.id, :is_deleted => true).count
      total = Post.where("created_at >= ?", date).where(:uploader_id => user.id).count
      ci_lower_bound(deletions, total)
    end

    def self.negative_score_confidence_interval_for(user, days = nil)
      date = (days || 60).days.ago
      hits = Post.where("created_at >= ? and score < 0", date).where(:uploader_id => user.id).count
      total = Post.where("created_at >= ?", date).where(:uploader_id => user.id).count
      ci_lower_bound(hits, total)
    end

    def self.ci_lower_bound(pos, n, confidence = 0.95)
      if n == 0
        return 0
      end

      z = Statistics2.pnormaldist(1 - (1 - confidence) / 2)
      phat = 1.0 * pos / n
      100 * (phat + z * z / (2 * n) - z * Math.sqrt((phat * (1 - phat) + z * z / (4 * n)) / n)) / (1 + z * z / n)
    end

    def self.min_time
      30.days.ago
    end

    def users
      ::User.where("users.bit_prefs & ? = 0 and users.post_upload_count >= 250", ::User.flag_value_for("can_upload_free")).order("created_at desc").map {|x| Reports::UserPromotions::User.new(x)}
    end
  end
end
