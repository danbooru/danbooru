import AlpineCookieStorage from "./alpine_cookie_storage";

export default class SidebarComponent {
  constructor(container) {
    this.$container = $(container);
    this.dock = Alpine.$persist(this.$container.data("dock")).as("sidebar_dock").using(AlpineCookieStorage);
  }
}
