module Moderator
  module Dashboard
    module Queries
      class PostAppeal
        def self.all(min_date)
          ::Post.joins(:appeals).includes(:uploader, :flags, appeals: [:creator])
            .deleted
            .where("post_appeals.created_at > ?", min_date)
            .group(:id)
            .order("count(*) desc")
            .limit(10)
        end
      end
    end
  end
end
