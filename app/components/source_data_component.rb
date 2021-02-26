# frozen_string_literal: true

class SourceDataComponent < ApplicationComponent
  attr_reader :source
  delegate :spinner_icon, to: :helpers

  def initialize(source:)
    @source = source
  end
end
