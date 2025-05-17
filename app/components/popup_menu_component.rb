# frozen_string_literal: true

# A component that shows a "..." button that when clicked displays a popup menu.
class PopupMenuComponent < ApplicationComponent
  attr_reader :hide_on_click, :classes, :button_classes, :button_html

  renders_one :button
  renders_many :items, ->(hide_on_click: nil, **options, &block) do
    tag.li(block.call, "data-hide-on-click": hide_on_click, **options)
  end

  # @param hide_on_click [Boolean] If true, then automatically hide the menu when anything inside the menu is clicked.
  # @param classes [String] A list of CSS classes for the root element.
  # @param button_classes [String] A list of CSS classes for the button element.
  # @param button_html [Hash] Options for the button element.
  def initialize(hide_on_click: true, classes: nil, button_classes: "default-popup-menu-button", button_html: {})
    @hide_on_click = hide_on_click
    @classes = classes
    @button_classes = button_classes
    @button_html = button_html
  end
end
