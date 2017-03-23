module Moderator
  module Dashboard
    module Queries
      class Note < ::Struct.new(:user, :count)
        def self.all(min_date, max_level)
          ::NoteVersion.joins(:updater)
            .where("note_versions.created_at > ?", min_date)
            .where("users.level <= ?", max_level)
            .group(:updater)
            .order("count(*) desc")
            .limit(10)
            .count
            .map { |user, count| new(user, count) }
        end
      end
    end
  end
end
