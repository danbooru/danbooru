module Moderator
  module Dashboard
    module Queries
      class Artist
        attr_reader :user, :count

        def self.all(min_date, max_level)
          sql = <<-EOS
            SELECT artist_versions.updater_id AS updater_id, count(*)
            FROM artist_versions
            JOIN users ON users.id = artist_versions.updater_id
            WHERE
              artist_versions.created_at > ?
              AND users.level <= ?
            GROUP BY artist_versions.updater_id
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
