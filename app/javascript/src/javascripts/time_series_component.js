import * as echarts from "echarts";
import startCase from "lodash/startCase";
import CurrentUser from "./current_user.js";

export default class TimeSeriesComponent {
  constructor({ container = null, data = [], columns = [], theme = null } = {}) {
    this.container = container;
    this.data = data;
    this.columns = columns;
    this.theme = CurrentUser.darkMode() ? "dark" : null;

    this.options = {
      dataset: {
        dimensions: ["date", ...this.columns],
        source: data,
      },
      tooltip: {
        trigger: "axis",
        axisPointer: {
          type: "cross",
          label: {
            backgroundColor: '#6a7985'
          }
        }
      },
      toolbox: {
        feature: {
          dataView: {},
          dataZoom: {
            yAxisIndex: "none"
          },
          magicType: {
            type: ["line", "bar"],
          },
          restore: {},
          saveAsImage: {}
        }
      },
      dataZoom: [
        { type: "inside" },
        { type: "slider" }
      ],
      grid: {
        left: "1%",
        right: "1%",
        containLabel: true
      },
      legend: {
        data: this.columns.map(startCase),
      },
      xAxis: { type: "time" },
      yAxis: this.columns.map(name => ({ type: "value" })),
      series: this.columns.map(name => ({
        name: startCase(name),
        type: "line",
        areaStyle: {},
        stack: "all",
        emphasis: {
          focus: "series"
        },
        encode: {
          x: "date",
          y: name
        }
      }))
    };

    this.chart = echarts.init(container, this.theme);
    this.chart.setOption(this.options);

    $(window).on("resize.danbooru", () => this.chart.resize());
  }
}
