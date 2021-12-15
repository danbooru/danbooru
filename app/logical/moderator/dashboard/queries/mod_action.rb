# frozen_string_literal: true

module Moderator
  module Dashboard
    module Queries
      class ModAction
        def self.all
          ::ModAction.includes(:creator).order("id desc").limit(10)
        end
      end
    end
  end
end
