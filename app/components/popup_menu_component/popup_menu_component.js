import { delegate } from 'tippy.js';
import 'tippy.js/dist/tippy.css';

class PopupMenuComponent {
  static initialize() {
    delegate("body", {
      allowHTML: true,
      interactive: true,
      theme: "common-tooltip",
      target: "a.popup-menu-button",
      placement: "bottom-start",
      trigger: "click",
      content: PopupMenuComponent.content,
    });
  }

  static content(element) {
    let $content = $(element).parents(".popup-menu").find(".popup-menu-content");
    $content.show();
    return $content.get(0);
  }
}

$(document).ready(PopupMenuComponent.initialize);

export default PopupMenuComponent;
