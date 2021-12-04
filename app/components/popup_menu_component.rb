# frozen_string_literal: true

class PopupMenuComponent < ApplicationComponent
  include ViewComponent::SlotableV2

  attr_reader :classes

  renders_one :button
  renders_many :items

  # @param classes [String] A list of CSS classes for the root element.
  def initialize(classes: nil)
    @classes = classes
  end
end
