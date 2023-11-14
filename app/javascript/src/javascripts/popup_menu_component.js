import { createTooltip } from './utility';

class PopupMenuComponent {
  static initialize() {
    createTooltip("popup-menu-tooltip", {
      target: "a.popup-menu-button",
      placement: "bottom-start",
      trigger: "click",
      touch: "hold",
      appendTo: "parent",
      animation: null,
      content: PopupMenuComponent.content,
    });

    $(document).on("click.danbooru", ".popup-menu-content", PopupMenuComponent.onMenuItemClicked);
  }

  static content(element) {
    let $content = $(element).parents(".popup-menu").find(".popup-menu-content");
    $content.show();
    return $content.get(0);
  }

  // Hides the menu when a menu item is clicked.
  static onMenuItemClicked(event) {
    let menuHideOnClick = $(event.target).parents(".popup-menu").data("hide-on-click");
    let itemHideOnClick = $(event.target).parents("li").data("hide-on-click");
    let hideOnClick = itemHideOnClick !== undefined ? itemHideOnClick : menuHideOnClick;

    if (hideOnClick) {
      let tippy = $(event.target).parents("[data-tippy-root]").get(0)?._tippy;
      tippy?.hide();
    }
  }
}

$(document).ready(PopupMenuComponent.initialize);

export default PopupMenuComponent;
