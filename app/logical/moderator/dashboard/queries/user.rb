module Moderator
  module Dashboard
    module Queries
      class User
        attr_reader :user, :count

        def initialize(hash)
          @user = User.find(hash["user_id"])
          @count = hash["count"]
        end
      end
    end
  end
end