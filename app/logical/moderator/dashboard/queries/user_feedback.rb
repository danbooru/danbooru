module Moderator
  module Dashboard
    module Queries
      class UserFeedback
        def self.all
          ::UserFeedback.order("id desc").limit(10)
        end
      end
    end
  end
end
