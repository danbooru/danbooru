# frozen_string_literal: true

# A "?" icon that when clicked show a help tooltip.
class HelpTooltipComponent < ApplicationComponent
  attr_reader :icon, :tooltip_content, :link_class

  def initialize(icon, tooltip_content, link_class: nil)
    @icon = icon
    @tooltip_content = tooltip_content
    @link_class = link_class
  end
end
