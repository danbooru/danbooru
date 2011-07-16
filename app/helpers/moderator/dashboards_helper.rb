module Moderator
  module DashboardsHelper
    def user_level_select_tag(name, options = {})
      choices = [
        ["", ""],
        ["Member", 0],
        ["Privileged", 100],
        ["Contributor", 200],
        ["Janitor", 300],
        ["Moderator", 400],
        ["Admin", 500]
      ]
      
      select_tag(name, options_for_select(choices, params[name].to_i), options)
    end
  end
end
