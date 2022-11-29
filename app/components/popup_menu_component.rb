# frozen_string_literal: true

# A component that shows a "..." button that when clicked displays a popup menu.
class PopupMenuComponent < ApplicationComponent
  include ViewComponent::SlotableV2

  attr_reader :hide_on_click, :classes

  renders_one :button
  renders_many :items, ->(hide_on_click: nil, &block) do
    tag.li(block.call, "data-hide-on-click": hide_on_click)
  end

  # @param hide_on_click [Boolean] If true, then automatically hide the menu when anything inside the menu is clicked.
  # @param classes [String] A list of CSS classes for the root element.
  def initialize(hide_on_click: true, classes: nil)
    @hide_on_click = hide_on_click
    @classes = classes
  end
end
