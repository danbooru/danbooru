module Moderator
  module Dashboard
    module Queries
      class Comment < ::Struct.new(:comment, :count)
        def self.all(min_date, max_level)
          ::CommentVote.joins(comment: [:creator])
            .where("comments.score < 0")
            .where("comment_votes.created_at > ?", min_date)
            .where("users.level <= ?", max_level)
            .group(:comment)
            .having("count(*) >= 3")
            .order("count(*) desc")
            .limit(10)
            .count
            .map { |comment, count| new(comment, count) }
        end
      end
    end
  end
end
