# frozen_string_literal: true

class TimeSeriesComponent < ApplicationComponent
  delegate :current_page_path, :search_params, to: :helpers

  attr_reader :dataframe, :x_axis, :y_axis, :mode

  def initialize(dataframe, x_axis:, mode: :table)
    @dataframe = dataframe
    @x_axis = x_axis
    @y_axis = columns.without(x_axis)
    @mode = mode.to_sym
  end

  def columns
    dataframe.types.keys
  end

  def chart_height
    if x_axis != "date"
      dataframe[x_axis]&.size.to_i * 30
    end
  end

  def chart_options
    if x_axis == "date"
      stacked_area_chart
    else
      horizontal_bar_chart
    end
  end

  def base_options
    {
      dataset: {
        dimensions: columns,
        source: dataframe.each_row.map(&:values),
      },
      tooltip: {
        trigger: "axis",
        axisPointer: {
          type: "cross",
          label: {
            backgroundColor: "#6a7985"
          }
        }
      },
      toolbox: {
        feature: {
          dataView: {},
          restore: {},
          saveAsImage: {}
        }
      },
      grid: {
        left: "1%",
        right: "1%",
        containLabel: true
      },
      legend: {
        data: y_axis,
        type: "scroll",
        left: 0,
        padding: [8, 200, 0, 15],
        orient: "horizontal",
      },
    }
  end

  def stacked_area_chart
    base_options.deep_merge(
      toolbox: {
        feature: {
          dataZoom: {
            yAxisIndex: "none"
          },
          magicType: {
            type: ["line", "bar"],
          },
        }
      },
      dataZoom: [
        { type: "inside" },
        { type: "slider" }
      ],
      xAxis: { type: "time" },
      yAxis: [type: "value"] * y_axis.size,
      series: y_axis.map do |name|
        {
          name: name,
          type: "line",
          areaStyle: {},
          stack: "all",
          emphasis: {
            focus: "series"
          },
          encode: {
            x: x_axis,
            y: name
          }
        }
      end
    )
  end

  def horizontal_bar_chart
    base_options.deep_merge(
      xAxis: { type: "value" },
      yAxis: [type: "category", inverse: true] * y_axis.size,
      series: y_axis.map do |name|
        {
          name: name,
          type: "bar",
          emphasis: {
            focus: "series"
          },
          encode: {
            x: name,
            y: x_axis,
          }
        }
      end
    )
  end
end
