# frozen_string_literal: true

class TimeSeriesComponent < ApplicationComponent
  delegate :current_page_path, :search_params, to: :helpers

  attr_reader :results, :columns, :mode

  def initialize(results, columns, mode: :table)
    @results = results
    @columns = columns
    @mode = mode.to_sym
  end
end
