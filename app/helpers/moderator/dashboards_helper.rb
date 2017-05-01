module Moderator
  module DashboardsHelper
    def user_level_select_tag(name, options = {})
      choices = [
        ["", ""],
        ["Member", 20],
        ["Gold", 30],
        ["Platinum", 31],
        ["Moderator", 40],
        ["Admin", 50]
      ]

      select_tag(name, options_for_select(choices, params[name].to_i), options)
    end
  end
end
