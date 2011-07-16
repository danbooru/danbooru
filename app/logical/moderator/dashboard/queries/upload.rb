module Moderator
  module Dashboard
    module Queries
      class Upload
        def self.all(min_date)
          ActiveRecord::Base.without_timeout do
            @upload_activity = ActiveRecord::Base.select_all_sql("select posts.uploader_string, count(*) from posts join users on posts.user_id = users.id where posts.created_at > ? and users.level <= ? group by posts.user_id order by count(*) desc limit 10", min_date, max_level).map {|x| UserActivity.new(x)}
          end
        end
      end
    end
  end
end
