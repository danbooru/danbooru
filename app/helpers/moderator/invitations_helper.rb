module Moderator
  module InvitationsHelper
    def level_select
      choices = []
      choices << ["Gold", User::Levels::GOLD]
      choices << ["Contributor", User::Levels::CONTRIBUTOR]
      select(:invitation, :level, choices)
    end
  end
end
