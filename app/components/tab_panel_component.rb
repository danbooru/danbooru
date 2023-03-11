# frozen_string_literal: true

class TabPanelComponent < ApplicationComponent
  Panel = Data.define(:name, :id, :index, :url, :active, :classes)
  MenuItem = Data.define(:id, :classes, :content, :active)
  Spacer = Data.define(:active)

  attr_reader :tabs, :classes, :tab_list_classes, :index, :html

  renders_many :panels

  def initialize(classes: "horizontal-tab-panel", tab_list_classes: nil, html: {})
    @tabs = []
    @classes = classes
    @tab_list_classes = tab_list_classes
    @index = 0
    @html = html
    yield self
  end

  def panel(name, id: "#{name.parameterize}-tab", index: @index, url: "#", active: false, classes: nil, &block)
    tabs << Panel.new(name:, id:, index:, url:, active:, classes:)
    with_panel(&block)
    @index += 1
  end

  def menu_item(id: nil, classes: nil, &block)
    tabs << MenuItem.new(id:, classes:, active: false, content: block)
  end

  def spacer
    tabs << Spacer.new(active: false)
  end

  def default_tab
    @default_tab ||= tabs.find(&:active)
  end
end
