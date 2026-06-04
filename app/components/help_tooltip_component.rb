# frozen_string_literal: true

# A "?" icon that when clicked show a help tooltip.
class HelpTooltipComponent < ApplicationComponent
  attr_reader :icon, :tooltip_content, :link_class

  def initialize(icon, tooltip_content, link_class: nil, tooltip_options: {})
    @icon = icon
    @tooltip_content = tooltip_content
    @link_class = link_class
    @tooltip_options = tooltip_options
  end

  def tooltip_options
    helpers.data_attributes_for(@tooltip_options, "data", @tooltip_options)
  end
end
