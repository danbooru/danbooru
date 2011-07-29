module Moderator
  module InvitationsHelper
    def level_select
      choices = []
      choices << ["Privileged", User::Levels::PRIVILEGED]
      choices << ["Contributor", User::Levels::CONTRIBUTOR]
      select(:invitation, :level, choices)
    end
  end
end
