module Moderator
  module Dashboard
    module Queries
      class Comment
        attr_reader :comment, :count

        def initialize(hash)
          @comment = Comment.find(hash["comment_id"])
          @count = hash["count"]
        end
      end
    end
  end
end
