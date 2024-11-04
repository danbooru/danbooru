# frozen_string_literal: true

# A component that shows a "..." button that when clicked displays a popup menu.
class PopupMenuComponent < ApplicationComponent
  attr_reader :hide_on_click, :classes, :button_classes

  renders_one :button
  renders_many :items, ->(hide_on_click: nil, &block) do
    tag.li(block.call, "data-hide-on-click": hide_on_click)
  end

  # @param hide_on_click [Boolean] If true, then automatically hide the menu when anything inside the menu is clicked.
  # @param classes [String] A list of CSS classes for the root element.
  # @param button_classes [String] A list of CSS classes for the button element.
  def initialize(hide_on_click: true, classes: nil, button_classes: "default-popup-menu-button")
    @hide_on_click = hide_on_click
    @classes = classes
    @button_classes = button_classes
  end

  def render_votes_toggle(show_votes)
    if show_votes
      link_to "Hide scores", url_for(**params.merge(show_votes: nil).except(:z).permit!), class: "post-preview-hide-votes", rel: "nofollow"
    else
      link_to "Show scores", url_for(**params.merge(show_votes: true).except(:z).permit!), class: "post-preview-show-votes", rel: "nofollow"
    end
  end
end
