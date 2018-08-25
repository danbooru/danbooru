#!/usr/bin/env ruby

require File.expand_path(File.join(File.dirname(__FILE__), '..', '..', 'config', 'environment'))

CurrentUser.user = User.system
CurrentUser.ip_addr = "127.0.0.1"

ModAction.transaction do
  ModAction.without_timeout do
    # Find mod actions where the user changed their own level.
    mod_actions = ModAction.where(category: :user_level_change).select do |mod_action|
      mod_action.description.match?(%r{".*":/users/#{mod_action.creator_id} level changed \w+ -> (Gold|Platinum)}i)
    end

    ModAction.where(id: mod_actions).update_all(category: :user_account_upgrade)
  end
end
