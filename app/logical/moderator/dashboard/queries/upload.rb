module Moderator
  module Dashboard
    module Queries
      class Upload < ::Struct.new(:user, :count)
        def self.all(min_date, max_level)
          ::Post.joins(:uploader)
            .where("posts.created_at > ?", min_date)
            .where("users.level <= ?", max_level)
            .group(:uploader)
            .order("count(*) desc")
            .limit(10)
            .count
            .map { |user, count| new(user, count) }
        end
      end
    end
  end
end
