module Moderator
  module Dashboard
    module Queries
      class WikiPage
        attr_reader :user, :count

        def self.all(min_date, max_level)
          sql = <<-EOS
            SELECT wiki_page_versions.updater_id, count(*)
            FROM wiki_page_versions
            JOIN users ON users.id = wiki_page_versions.updater_id
            WHERE
              wiki_page_versions.created_at > ?
              AND users.level <= ?
            GROUP BY wiki_page_versions.updater_id
            ORDER BY count(*) DESC
            LIMIT 10
          EOS

          ActiveRecord::Base.select_all_sql(sql, min_date, max_level).map {|x| new(x)}
        end

        def initialize(hash)
          @user = ::User.find(hash["updater_id"])
          @count = hash["count"]
        end
      end
    end
  end
end
