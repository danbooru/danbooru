import Alpine from "@alpinejs/csp";

export default class Notice {
  constructor(message = "") {
    this.message = message;
    this.isOpen = message ? true : false;
    this.type = "info";
    this.timeout = null;
  }

  // Render the message into `element`. Messages are HTML, so callers must escape user text.
  //
  // @param {HTMLElement} element - The element to render the message into.
  render(element) {
    element.innerHTML = this.message;
  }

  show(message, autoclose = true, type = "info") {
    this.message = message;
    this.type = type;
    this.open(autoclose);
  }

  open(autoclose = true) {
    this.isOpen = true;

    clearTimeout(this.timeout);
    if (autoclose) {
      this.timeout = setTimeout(() => this.close(), 6000);
    }
  }

  close() {
    this.isOpen = false;
    clearTimeout(this.timeout);
  }

  static get notice() {
    return $("#notice").get(0).notice;
  }

  static info(message) {
    $(() => Notice.notice.show(message, true, "info"));
  }

  static error(message) {
    $(() => Notice.notice.show(message, false, "error"));
  }
}

// The global notice at the top of the page. The initial message is read from the server-rendered HTML instead of taken
// as an argument, so injected HTML can't use `x-data="noticeComponent('<html>')"` to render arbitrary HTML.
Alpine.data("noticeComponent", () => ({
  notice: null,

  init() {
    this.notice = new Notice(this.$el.querySelector(".prose").innerHTML.trim());

    // Attach the notice to the root element for access with `Notice.notice`.
    this.$el.notice = this.notice;
  },
}));
