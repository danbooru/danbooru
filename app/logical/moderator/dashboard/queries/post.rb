module Moderator
  module Dashboard
    module Queries
      class Post
        attr_reader :post, :count

        def initialize(hash)
          @post = Post.find(hash["post_id"])
          @count = hash["count"]
        end
      end
    end
  end
end
