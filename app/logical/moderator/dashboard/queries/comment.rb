module Moderator
  module Dashboard
    module Queries
      class Comment
        attr_reader :comment, :count

        def self.all(min_date, max_level)
          sql = <<-EOS
            SELECT comment_votes.comment_id, count(*)
            FROM comment_votes
            JOIN comments ON comments.id = comment_id
            JOIN users ON users.id = comments.creator_id
            WHERE
              comment_votes.created_at > ?
              AND comments.score < 0
              AND users.level <= ?
            GROUP BY comment_votes.comment_id
            HAVING count(*) >= 3
            ORDER BY count(*) DESC
            LIMIT 10
          EOS

          ActiveRecord::Base.select_all_sql(sql, min_date, max_level).map {|x| new(x)}
        end

        def initialize(hash)
          @comment = ::Comment.find(hash["comment_id"])
          @count = hash["count"]
        end
      end
    end
  end
end
