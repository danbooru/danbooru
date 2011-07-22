module Moderator
  module Dashboard
    module Queries
      class Tag
        attr_reader :user, :count
        
        def self.all(min_date, max_level)
          sql = <<-EOS
            SELECT post_versions.updater_id, count(*) 
            FROM post_versions 
            JOIN users ON users.id = post_versions.updater_id 
            WHERE 
              post_versions.created_at > ? 
              AND users.level <= ? 
            GROUP BY post_versions.updater_id 
            ORDER BY count(*) DESC 
            LIMIT 10
          EOS
          
          ActiveRecord::Base.without_timeout do
            ActiveRecord::Base.select_all_sql(sql, min_date, max_level).map {|x| new(x)}
          end
        end
        
        def initialize(hash)
          @user = ::User.find(hash["updater_id"])
          @count = hash["count"]
        end
      end
    end
  end
end
