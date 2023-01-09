# frozen_string_literal: true

class TabPanelComponent < ApplicationComponent
  attr_reader :tabs, :classes

  renders_many :panels

  def initialize(classes: "horizontal-tab-panel")
    @tabs = []
    @classes = classes
    yield self
  end

  def panel(name:, url: "#", active: false, &block)
    tabs << OpenStruct.new(name:, url:, active:)
    with_panel(&block)
  end
end
