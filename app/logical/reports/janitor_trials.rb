module Reports
  class JanitorTrials
    class Janitor
      attr_reader :user

      def initialize(user)
        @user = user
      end

      def trial
        JanitorTrial.where(user_id: user.id).first
      end

      def created_at
        trial.created_at
      end

      def since
        3.months.ago
      end

      def approval_count
        @approval_count ||= Post.where("approver_id = ? and created_at >= ?", user.id, since).count
      end

      def percentile_25_score
        ActiveRecord::Base.select_value_sql("select percentile_cont(0.25) within group (order by score) from posts where created_at >= ? and approver_id = ?", since, user.id).to_i
      end

      def percentile_50_score
        ActiveRecord::Base.select_value_sql("select percentile_cont(0.50) within group (order by score) from posts where created_at >= ? and approver_id = ?", since, user.id).to_i
      end

      def deletion_chance
        hits = Post.where("approver_id = ? and created_at >= ? and is_deleted = true", user.id, since).count
        total = Post.where("approver_id = ? and created_at >= ?", user.id, since).count
        Reports::UserPromotions.ci_lower_bound(hits, total, 0.95).to_i
      end

      def neg_score_chance
        hits = Post.where("approver_id = ? and created_at >= ? and score < 0", user.id, since).count
        total = Post.where("approver_id = ? and created_at >= ?", user.id, since).count
        Reports::UserPromotions.ci_lower_bound(hits, total, 0.95).to_i
      end
    end

    def janitors
      User.where("bit_prefs & ? > 0", User.flag_value_for("can_approve_posts")).to_a.map {|x| Janitor.new(x)}
    end
  end
end
