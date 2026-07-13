# frozen_string_literal: true

class SidebarComponent < ApplicationComponent
  attr_reader :dock_position

  def initialize(sidebar_dock: nil)
    @dock_position = Danbooru::JSON.parse(sidebar_dock)
    @dock_position = "default" if !dock_position.in?(%w[default left right])
    super
  end
end
