# frozen_string_literal: true

class TimeSeriesComponent < ApplicationComponent
  delegate :current_page_path, :search_params, to: :helpers

  attr_reader :dataframe, :group, :mode

  def initialize(dataframe, group: nil, mode: :table)
    @dataframe = dataframe
    @group = group
    @mode = mode.to_sym
  end
end
