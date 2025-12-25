export default class Notice {
  constructor(message = "") {
    this.message = message;
    this.isOpen = message ? true : false;
    this.type = "info";
    this.timeout = null;
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
