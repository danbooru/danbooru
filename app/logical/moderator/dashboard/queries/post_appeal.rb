module Moderator
  module Dashboard
    module Queries
      class PostAppeal
        attr_reader :post, :count

        def self.all(min_date)
          sql = <<-EOS
            SELECT post_appeals.post_id, count(*)
            FROM post_appeals
            JOIN posts ON posts.id = post_appeals.post_id
            WHERE
              post_appeals.created_at > ?
              and posts.is_deleted = true
              and posts.is_pending = false
            GROUP BY post_appeals.post_id
            ORDER BY count(*) DESC
            LIMIT 10
          EOS

          ActiveRecord::Base.select_all_sql(sql, min_date).map {|x| new(x)}
        end

        def initialize(hash)
          @post = ::Post.find(hash["post_id"])
          @count = hash["count"]
        end
      end
    end
  end
end
