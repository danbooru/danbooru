import { createTooltip } from './utility';

class HelpTooltipComponent {
  static initialize() {
    createTooltip("help-tooltip", {
      target: "a.help-tooltip-link",
      trigger: "click",
      touch: "hold",
      duration: 50,
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
