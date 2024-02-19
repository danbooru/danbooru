import Utility, { createTooltip } from './utility';

class PaginatorJumpComponent {
  static initialize() {
    createTooltip("popup-page-jump-menu", {
      target: ".paginator>.paginator-jump-popup-button",
      placement: "top",
      trigger: "click",
      touch: "hold",
      appendTo: "parent",
      animation: null,
      content: PaginatorJumpComponent.content,
      onShow: PaginatorJumpComponent.beforeShow,
      onMount: PaginatorJumpComponent.onMount
    });
  }

  static beforeShow(tippyInstance) {
    const nodeType = tippyInstance.reference.nodeName
    const isDesktop = !Utility.isMobile()
    // If current page number is clicked and is on desktop popup will not show
    if (nodeType === "SPAN" && isDesktop) {
      return false
    }
    return true
  }

  // Setup interactivity
  static onMount(tippyInstance) {
    const $input = $("#jumpto-input-box")

    // Clear all previous state
    $input.val('')
    PaginatorJumpComponent.clearErrorMessage()

    // Autofocus input box when shown
    $input.trigger("focus")

    const onSubmit = () => {
      const index = parseInt($input.val())
      const lastPage = parseInt($input.attr('max'))
      if (isNaN(index)) {
        PaginatorJumpComponent.setErrorMessage("An error accured.")
        return
      }
      if (index < 1) {
        PaginatorJumpComponent.setErrorMessage("Page number start at 1.")
        return
      }
      if (index > lastPage) {
        if (lastPage === 1) {
          PaginatorJumpComponent.setErrorMessage("There is only 1 page.")
        } else {
          PaginatorJumpComponent.setErrorMessage(`There are only ${lastPage} pages.`)
        }
        return
      }
      PaginatorJumpComponent.clearErrorMessage()
      PaginatorJumpComponent.jumpToPage(index)
      tippyInstance.hide()
    }

    $("#jumpto-button").on('click', onSubmit)
    $input.on('keyup', function (e) {
      if (e.key === 'Enter') {
        onSubmit()
      }
    });
  }

  static content() {
    let template = document.getElementById("jumpto-template");
    return template?.innerHTML ?? "";
  }

  static jumpToPage(index) {
    const url = window.location.href
    const regex = /page=\d{1,}/
    let newUrl = url;
    if (!url.match(regex)) {
      if (url.includes('?')) {
        newUrl += `&page=${index}`
      } else {
        newUrl += `?page=${index}`
      }
    } else {
      newUrl = url.replace(regex, `page=${index}`)
    }
    // Cancel if navigate to current page
    if (url !== newUrl) {
      window.location.href = newUrl
    }
  }

  static setErrorMessage(message) {
    $("#jumpto-error").text(message)
  }

  static clearErrorMessage() {
    $("#jumpto-error").text("")
  }

}

$(document).ready(PaginatorJumpComponent.initialize);

export default PaginatorJumpComponent;
