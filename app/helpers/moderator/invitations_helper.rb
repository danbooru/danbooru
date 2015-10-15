module Moderator
  module InvitationsHelper
    def level_select
      choices = []
      choices << ["Gold", User::Levels::GOLD]
      choices << ["Platinum", User::Levels::PLATINUM]
      select(:invitation, :level, choices)
    end
  end
end
