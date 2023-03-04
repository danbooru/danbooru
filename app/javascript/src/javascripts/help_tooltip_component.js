import { delegate } from 'tippy.js';
import 'tippy.js/dist/tippy.css';

class HelpTooltipComponent {
  static initialize() {
    delegate("body", {
      allowHTML: true,
      interactive: true,
      theme: "common-tooltip help-tooltip",
      target: "a.help-tooltip-link",
      placement: "top",
      trigger: "click",
      maxWidth: "none",
      duration: 50,
      touch: "hold",
      appendTo: document.querySelector("#tooltips"),
      content(element) {
        let $content = $(element).next(".help-tooltip-content");
        $content.show();
        return $content.get(0);
      }
    });
  }
}

$(document).ready(HelpTooltipComponent.initialize);

export default HelpTooltipComponent;
