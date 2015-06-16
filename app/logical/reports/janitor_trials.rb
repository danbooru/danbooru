module Reports
  class JanitorTrials
    class Janitor
      attr_reader :trial

      def initialize(trial)
        @trial = trial
      end

      def user
        trial.user
      end

      def since
        3.months.ago
      end

      def approval_count
        @approval_count ||= Post.where("approver_id = ? and created_at >= ?", user.id, since).count
      end

      def deleted_count
        Post.where("approver_id = ? and created_at >= ? and is_deleted = true", user.id, since).count
      end

      def percentile_25_score
        ActiveRecord::Base.select_value_sql("select percentile_cont(0.25) within group (order by score) from posts where created_at >= ? and approver_id = ?", since, user.id).to_i
      end

      def percentile_50_score
        ActiveRecord::Base.select_value_sql("select percentile_cont(0.50) within group (order by score) from posts where created_at >= ? and approver_id = ?", since, user.id).to_i
      end

      def rating_e_percentage
        100 * Post.where("approver_id = ? and created_at >= ? and rating = 'e'", user.id, since).count.to_f / [approval_count, 1].max
      end

      def rating_q_percentage
        100 * Post.where("approver_id = ? and created_at >= ? and rating = 'q'", user.id, since).count.to_f / [approval_count, 1].max
      end

      def rating_s_percentage
        100 * Post.where("approver_id = ? and created_at >= ? and rating = 's'", user.id, since).count.to_f / [approval_count, 1].max
      end
    end

    def janitors
      JanitorTrial.where(status: "active").to_a.map {|x| Janitor.new(x)}
    end
  end
end
