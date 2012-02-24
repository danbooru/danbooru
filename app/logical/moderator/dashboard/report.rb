module Moderator
  module Dashboard
    class Report
      attr_reader :min_date, :max_level
      
      def initialize(min_date, max_level)
        @min_date = min_date.present? ? min_date.to_date : 1.week.ago
        @max_level = max_level.present? ? User::Levels::MEMBER : max_level.to_i
      end
      
      def artists
        Queries::Artist.all(min_date, max_level)
      end
      
      def comments
        Queries::Comment.all(min_date, max_level)
      end

      def mod_actions
        Queries::ModAction.all
      end

      def notes
        Queries::Note.all(min_date, max_level)
      end

      def appeals
        Queries::PostAppeal.all(min_date)
      end

      def flags
        Queries::PostFlag.all(min_date)
      end

      def tags
        Queries::Tag.all(min_date, max_level)
      end

      def posts
        Queries::Upload.all(min_date, max_level)
      end
      
      def user_feedbacks
        Queries::UserFeedback.all
      end

      def wiki_pages
        Queries::WikiPage.all(min_date, max_level)
      end
    end
  end
end
