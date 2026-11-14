import CurrentUser from './current_user'
import { delay, isMobile } from './utility'

// Detects left and right swipes on mobile, and triggers `swipe:left` or `swipe:right` events on the element.
//
// We only watch where a touch starts and where it ends, then decide whether it was a swipe. Scrolling up and down,
// pinch zooming, and selecting text all keep working normally.
export default class Swipeable {
  static THRESHOLD = 60; // The minimum distance in pixels.
  static VELOCITY = 0.6; // The minimum speed in pixels per millisecond.
  static SLIDE_DURATION = 200; // How long the page takes to slide off the screen, in milliseconds.

  constructor(element) {
    this.element = element instanceof jQuery ? element.get(0) : element;

    // Where and when the current touch started. This is null if there's no touch in progress, or if the user is using
    // more than one finger (e.g. pinch zooming), since that can't be a swipe.
    this.touchStart = null;

    if (isMobile() && !CurrentUser.data("disable-mobile-gestures")) {
      this.initialize();
    }
  }

  initialize() {
    this.element.addEventListener("touchstart", event => this.onTouchStart(event), { passive: true });
    this.element.addEventListener("touchend", event => this.onTouchEnd(event), { passive: true });

    // The browser reads the touch action when a touch starts, so keep it up to date after anything that can zoom or
    // widen the page.
    this.updateTouchAction();
    window.visualViewport.addEventListener("resize", () => this.updateTouchAction());
    window.addEventListener("click", () => this.updateTouchAction());
  }

  onTouchStart(event) {
    this.updateTouchAction();

    if (event.touches.length !== 1) {
      this.touchStart = null;
      return;
    }

    this.touchStart = {
      x: event.touches[0].clientX,
      y: event.touches[0].clientY,
      time: event.timeStamp,
      element: event.target,
    };
  }

  onTouchEnd(event) {
    // Ignore multi-finger touches, and wait until the last finger is lifted.
    if (this.touchStart === null || event.touches.length > 0) {
      return;
    }

    const start = this.touchStart;
    const end = { x: event.changedTouches[0].clientX, y: event.changedTouches[0].clientY, time: event.timeStamp };
    this.touchStart = null;

    if (this.isSwipe(start, end) && this.canSwipeFrom(start.element)) {
      $(this.element).trigger(end.x < start.x ? "swipe:left" : "swipe:right", [event, this]);
    }
  }

  // A swipe is a quick, mostly horizontal movement over a minimum distance.
  isSwipe(start, end) {
    const distanceX = Math.abs(end.x - start.x);
    const distanceY = Math.abs(end.y - start.y);
    const speed = distanceX / (end.time - start.time); // In pixels per millisecond.

    return distanceX >= Swipeable.THRESHOLD && speed >= Swipeable.VELOCITY && distanceX > 2 * distanceY;
  }

  // Don't treat a touch as a swipe if the user is panning around a zoomed-in page, selecting text, typing in a form,
  // or scrolling something sideways.
  canSwipeFrom(element) {
    const isSelectingText = !window.getSelection().isCollapsed;
    const isInForm = element.closest("input, textarea, select, [contenteditable], .ui-dialog");

    return !this.isZoomedIn() && !isSelectingText && !isInForm && !this.isInSidewaysScroller(element);
  }

  isZoomedIn() {
    return window.visualViewport.scale > 1.01;
  }

  // True if the element is inside something that scrolls sideways, like a list of child posts.
  isInSidewaysScroller(element) {
    return $(element).parentsUntil(this.element).addBack().toArray().some(parent => {
      return parent.scrollWidth > parent.clientWidth && ["auto", "scroll"].includes(getComputedStyle(parent).overflowX);
    });
  }

  // The browser's back button skips pages that went to another page without the user interacting with them, and a
  // touch only counts as an interaction if the browser didn't use it to scroll. So don't let sideways swipes scroll
  // the page, unless the page is zoomed in or wider than the screen and the user needs to pan around it.
  updateTouchAction() {
    const isWiderThanScreen = document.documentElement.scrollWidth > document.documentElement.clientWidth;
    this.element.style.touchAction = this.isZoomedIn() || isWiderThanScreen ? "" : "pan-y pinch-zoom";
  }

  // Swipe left to go to the next page, and swipe right to go to the previous page. The page slides off the screen in
  // the direction of the swipe, like turning a page. Does nothing if there's no `a[rel~=next]` or `a[rel~=prev]` link.
  static navigateOnSwipe(element) {
    new Swipeable(element);

    $(element).on("swipe:left swipe:right", async event => {
      const swipedLeft = event.type === "swipe:left";
      const link = document.querySelector(swipedLeft ? "a[rel~=next]:not([hidden])" : "a[rel~=prev]:not([hidden])");

      if (!link) {
        return;
      }

      const duration = `${Swipeable.SLIDE_DURATION}ms`;
      $("body").css({ "transition": `opacity ${duration} ease, transform ${duration} ease`, "opacity": "0", "transform": `translateX(${swipedLeft ? "-150%" : "150%"})` });
      await delay(Swipeable.SLIDE_DURATION);
      location.href = link.href;
    });

    // If the user swipes to another page and then presses the back button, the browser may show this page exactly as
    // we left it, which is slid off the screen. Undo the slide so the page is visible again.
    window.addEventListener("pageshow", () => {
      $("body").css({ "transition": "", "opacity": "", "transform": "" });
    });
  }
}
