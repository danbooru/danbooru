import * as echarts from "echarts";
import CurrentUser from "./current_user.js";

export default class TimeSeriesComponent {
  constructor({ container = null, options = {} } = {}) {
    this.container = container;
    this.options = options;
    this.theme = CurrentUser.darkMode() ? "dark" : null;

    this.chart = echarts.init(container, this.theme);
    this.chart.setOption(this.options);

    $(window).on("resize.danbooru", () => this.chart.resize());
  }
}
