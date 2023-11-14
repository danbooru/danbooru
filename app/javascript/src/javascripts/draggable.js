export default class Draggable {
  constructor(selector) {
    this.selector = selector;
    this.initialize();
  }

  initialize() {
    $(document).on("pointerdown.danbooru", this.selector, (startEvent) => {
      if (startEvent.button !== 0 || !startEvent.originalEvent.isPrimary) {
        return; // Ignore right-clicks and multi-touch gestures.
      }

      let active = true;
      let target = startEvent.target;
      let pointerId = startEvent.pointerId;
      let namespace = `drag-${pointerId}`;

      target.setPointerCapture(pointerId);
      $(target).addClass("dragging");
      $(target).trigger("drag:start", [startEvent, this]);
      startEvent.preventDefault();

      $(document.body).on(`pointermove.${namespace}`, (moveEvent) => {
        requestAnimationFrame(() => {
          if (moveEvent.pointerId !== pointerId || !active) {
            return; // Ignore multi-touch gestures and pointermove events after pointerup has already been fired.
          }

          let movement = {
            x: moveEvent.clientX - startEvent.clientX,
            y: moveEvent.clientY - startEvent.clientY,
          };

          $(target).trigger("drag:move", [moveEvent, movement, this]);
          moveEvent.preventDefault();
        });
      });

      $(document.body).on(`pointerup.${namespace} pointercancel.${namespace}`, (endEvent) => {
        if (endEvent.pointerId !== pointerId) {
          return; // Ignore multi-touch gestures.
        }

        active = false;
        $(target).removeClass("dragging");
        $(document.body).off(`pointerup.${namespace} pointercancel.${namespace} pointermove.${namespace}`);

        $(target).trigger("drag:stop", [endEvent, this]);
        endEvent.preventDefault();
      });
    });
  }
}
