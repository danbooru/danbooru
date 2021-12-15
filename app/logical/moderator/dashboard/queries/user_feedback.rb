# frozen_string_literal: true

module Moderator
  module Dashboard
    module Queries
      class UserFeedback
        def self.all
          ::UserFeedback.includes(:user).order("id desc").limit(10)
        end
      end
    end
  end
end
