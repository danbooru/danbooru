module Moderator
  module Dashboard
    module Queries
      class Upload
        attr_reader :user, :count

        def self.all(min_date, max_level)
          sql = <<-EOS
            select uploader_id, count(*)
            from posts
            join users on uploader_id = users.id
            where
              posts.created_at > ?
              and level <= ?
            group by posts.uploader_id
            order by count(*) desc
            limit 10
          EOS

          ActiveRecord::Base.select_all_sql(sql, min_date, max_level).map {|x| new(x)}
        end

        def initialize(hash)
          @user = ::User.find(hash["uploader_id"])
          @count = hash["count"]
        end
      end
    end
  end
end
