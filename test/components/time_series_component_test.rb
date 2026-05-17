require "test_helper"

class TimeSeriesComponentTest < ViewComponent::TestCase
  context "The TimeSeriesComponent" do
    should "render tabular results by default" do
      TimeSeriesComponent.any_instance.stubs(:current_page_path).returns("/reports")
      TimeSeriesComponent.any_instance.stubs(:search_params).returns({})

      dataframe = Danbooru::DataFrame.new([
        { date: Date.new(2024, 1, 1), posts: 5 },
      ])

      render_inline(TimeSeriesComponent.new(dataframe, x_axis: "date"))

      assert_css("table.striped")
      assert_css("th", text: "Date")
      assert_css("td", text: "5")
    end

    should "render a stacked area chart for date x-axis" do
      TimeSeriesComponent.any_instance.stubs(:current_page_path).returns("/reports")
      TimeSeriesComponent.any_instance.stubs(:search_params).returns({})

      dataframe = Danbooru::DataFrame.new([
        { date: Date.new(2024, 1, 1), posts: 5, comments: 2 },
        { date: Date.new(2024, 1, 2), posts: 7, comments: 3 },
      ])

      render_inline(TimeSeriesComponent.new(dataframe, x_axis: "date", mode: :chart))

      assert_css(".line-chart")
      assert_css("a", text: "Table")
      assert_includes(rendered_content, '"type":"line"')
    end

    should "render a horizontal bar chart for non-date x-axis" do
      TimeSeriesComponent.any_instance.stubs(:current_page_path).returns("/reports")
      TimeSeriesComponent.any_instance.stubs(:search_params).returns({})

      dataframe = Danbooru::DataFrame.new([
        { tag: "blue_hair", posts: 5, comments: 2 },
        { tag: "red_hair", posts: 7, comments: 3 },
      ])

      render_inline(TimeSeriesComponent.new(dataframe, x_axis: "tag", mode: :chart))

      assert_css(".line-chart")
      assert_css("a", text: "Table")
      assert_includes(rendered_content, '"type":"bar"')
    end
  end
end
