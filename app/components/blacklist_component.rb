# frozen_string_literal: true

# A component that displays a user's blacklist rules, and that allows toggling them on and off.
class BlacklistComponent < ApplicationComponent
  attr_reader :user, :inline, :rules

  delegate :link_to_wiki, :chevron_down_icon, :chevron_right_icon, to: :helpers

  # @param user [User] The user whose blacklist rules to display.
  # @param inline [Boolean] Whether to render the rules on a single line or as a list.
  def initialize(user:, inline: false)
    super
    @user = user
    @inline = inline
    @rules = user.blacklist_rules
  end
end
