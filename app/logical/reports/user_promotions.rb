require 'statistics2'

module Reports
  class UserPromotions
    class User
      attr_reader :user
      delegate :name, :post_upload_count, :level_string, :level, :created_at, :to => :user

      def initialize(user)
        @user = user
      end

      def confidence_interval_for(n)
        Reports::UserPromotions.confidence_interval_for(user, n)
      end
    end

    def self.confidence_interval_for(user, n)
      up_votes = Post.where("created_at >= ?", min_time).where(:is_deleted => false, :uploader_id => user.id).where("score >= ?", n).count
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
      ::User.where("users.level < ? and users.post_upload_count >= 150", ::User::Levels::CONTRIBUTOR).order("created_at desc").limit(50).map {|x| Reports::UserPromotions::User.new(x)}
    end
  end
end
