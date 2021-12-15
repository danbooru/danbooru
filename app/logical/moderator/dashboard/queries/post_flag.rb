# frozen_string_literal: true

module Moderator
  module Dashboard
    module Queries
      class PostFlag
        attr_reader :post, :count

        def self.all(min_date)
          sql = <<-EOS
            SELECT post_flags.post_id, count(*)
            FROM post_flags
            JOIN posts ON posts.id = post_flags.post_id
            WHERE
              post_flags.created_at > ?
              AND post_flags.reason <> ?
              AND posts.is_deleted = false
              and posts.is_pending = false
            GROUP BY post_flags.post_id
            ORDER BY count(*) DESC
            LIMIT 10
          EOS

          ActiveRecord::Base.select_all_sql(sql, min_date, "Unapproved in three days").map {|x| new(x)}
        end

        def initialize(hash)
          @post = Post.find(hash["post_id"])
          @count = hash["count"]
        end
      end
    end
  end
end
