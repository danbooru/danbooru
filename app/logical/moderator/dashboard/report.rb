module Moderator
  module Dashboard
    class Report
      attr_reader :min_date, :max_level

      def initialize(min_date, max_level)
        @min_date = min_date.present? ? min_date.to_date : 1.week.ago
        @max_level = max_level.present? ? max_level.to_i : User::Levels::MEMBER
      end

      def artists
        ActiveRecord::Base.without_timeout do
          Queries::Artist.all(min_date, max_level)
        end
      end

      def comments
        ActiveRecord::Base.without_timeout do
          Queries::Comment.all(min_date, max_level)
        end
      end

      def mod_actions
        ActiveRecord::Base.without_timeout do
          Queries::ModAction.all
        end
      end

      def notes
        ActiveRecord::Base.without_timeout do
          Queries::Note.all(min_date, max_level)
        end
      end

      def appeals
        ActiveRecord::Base.without_timeout do
          Queries::PostAppeal.all(min_date)
        end
      end

      def flags
        ActiveRecord::Base.without_timeout do
          Queries::PostFlag.all(min_date)
        end
      end

      def tags
        Queries::Tag.all(min_date, max_level)
      end

      def posts
        ActiveRecord::Base.without_timeout do
          Queries::Upload.all(min_date, max_level)
        end
      end

      def user_feedbacks
        ActiveRecord::Base.without_timeout do
          Queries::UserFeedback.all
        end
      end

      def wiki_pages
        ActiveRecord::Base.without_timeout do
          Queries::WikiPage.all(min_date, max_level)
        end
      end
    end
  end
end
