import CurrentUser from './current_user'
import { delay, isMobile } from './utility'

// Detects left and right swipes on mobile, and triggers `swipe:left` or `swipe:right` events on the element.
//
// We only watch where a touch starts and where it ends, then decide whether it was a swipe. We never block the
// browser's own handling of touches, so scrolling, pinch zooming, and selecting text all keep working normally.
export default class Swipeable {
  static THRESHOLD = 60; // The minimum distance in pixels.
  static VELOCITY = 0.6; // The minimum speed in pixels per millisecond.

  constructor(element) {
    this.element = element instanceof jQuery ? element.get(0) : element;

    if (isMobile() && !CurrentUser.data("disable-mobile-gestures")) {
      this.initialize();
    }
  }

  initialize() {
    // Where and when the current touch started. This is null if there's no touch in progress, or if the user is using
    // more than one finger (e.g. pinch zooming), since that can't be a swipe.
    let touchStart = null;

    this.element.addEventListener("touchstart", event => {
      if (event.touches.length !== 1) {
        touchStart = null;
        return;
      }

      touchStart = {
        x: event.touches[0].clientX,
        y: event.touches[0].clientY,
        time: event.timeStamp,
        element: event.target,
      };
    }, { passive: true });

    this.element.addEventListener("touchend", event => {
      // Ignore multi-finger touches, and wait until the last finger is lifted.
      if (touchStart === null || event.touches.length > 0) {
        return;
      }

      const start = touchStart;
      touchStart = null;

      const end = event.changedTouches[0];
      const distanceX = end.clientX - start.x; // Negative if the finger moved left, positive if it moved right.
      const distanceY = end.clientY - start.y;
      const duration = event.timeStamp - start.time; // In milliseconds.
      const speed = Math.abs(distanceX) / duration; // In pixels per millisecond.

      // A swipe is a quick, mostly horizontal movement over a minimum distance.
      const movedFarEnough = Math.abs(distanceX) >= Swipeable.THRESHOLD;
      const movedFastEnough = speed >= Swipeable.VELOCITY;
      const movedMostlySideways = Math.abs(distanceX) > 2 * Math.abs(distanceY);

      // Don't treat it as a swipe if the user is panning around a zoomed-in page, selecting text, or typing in a form.
      const isZoomedIn = window.visualViewport.scale > 1.01;
      const isSelectingText = !window.getSelection().isCollapsed;
      const isInForm = start.element.closest("input, textarea, select, [contenteditable], .ui-dialog");

      if (movedFarEnough && movedFastEnough && movedMostlySideways && !isZoomedIn && !isSelectingText && !isInForm) {
        $(this.element).trigger(distanceX < 0 ? "swipe:left" : "swipe:right", [event, this]);
      }
    }, { passive: true });
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

      $("body").css({ "transition": "opacity 0.2s ease, transform 0.2s ease", "opacity": "0", "transform": `translateX(${swipedLeft ? "-150%" : "150%"})` });
      await delay(200);
      location.href = link.href;
    });

    // If the user swipes to another page and then presses the back button, the browser may show this page exactly as
    // we left it, which is slid off the screen. Undo the slide so the page is visible again.
    window.addEventListener("pageshow", () => {
      $("body").css({ "transition": "", "opacity": "", "transform": "" });
    });
  }
}
