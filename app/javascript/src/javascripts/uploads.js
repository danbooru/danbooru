import Cookie from "./cookie";
import Utility from "./utility";
import clamp from "lodash/clamp";

let Upload = {};

Upload.IQDB_LIMIT = 5;
Upload.IQDB_MIN_SIMILARITY = 50;
Upload.IQDB_HIGH_SIMILARITY = 70;

Upload.initialize_all = function() {
  if ($("#c-uploads #a-show #p-single-asset-upload").length) {
    this.initialize_similar();
    this.initialize_draggable_divider();
  }

  Upload.loadAssets();
}

Upload.loadAssets = async function() {
  while ($(".upload-media-asset-loading").length) {
    let ids = $(".upload-media-asset-loading").map((i, el) => $(el).attr("data-id")).toArray().join(",");
    let size = $(".upload-media-asset-gallery").attr("data-size");
    $.get("/upload_media_assets.js", { search: { status: "active failed", id: ids }, size: size });
    await Utility.delay(250);
  }
}

Upload.initialize_draggable_divider = function() {
  $(".upload-divider").on("pointerdown", (startEvent) => {
    if (startEvent.button !== 0 || !startEvent.originalEvent.isPrimary) {
      return; // Ignore right-clicks and multi-touch gestures.
    }

    let active = true;
    let dragStartWidth = $(".upload-edit-container").width();
    let panelWidth = dragStartWidth;
    let pointerId = startEvent.pointerId;
    startEvent.preventDefault();

    $(".upload-divider").get(0).setPointerCapture(pointerId);
    $(".upload-divider").addClass("dragging");

    $(document.body).on("pointermove", (moveEvent) => {
      requestAnimationFrame(() => {
        if (moveEvent.pointerId !== pointerId || !active) {
          return; // Ignore multi-touch gestures and pointermove events after pointerup has already been fired.
        }

        let dragOffsetX = moveEvent.clientX - startEvent.clientX;
        let minWidth = parseInt($(".upload-container").css("--min-edit-container-width"));
        let maxWidth = $(".upload-container").width() - minWidth;
        panelWidth = clamp(dragStartWidth - dragOffsetX, minWidth, maxWidth);
        $(".upload-container").css("--edit-container-width", panelWidth);

        moveEvent.preventDefault();
      });
    });

    $(document.body).on("pointerup pointercancel", (endEvent) => {
      if (endEvent.pointerId !== pointerId) {
        return; // Ignore multi-touch gestures.
      }

      active = false;
      $(document.body).off("pointerup pointercancel pointermove");
      $(".upload-divider").removeClass("dragging");
      Cookie.put("upload_edit_container_width", panelWidth);

      endEvent.preventDefault();
    });
  });
};

Upload.initialize_similar = function() {
  let media_asset_id = $("input[name='media_asset_id']").val();

  $.get("/iqdb_queries.js", {
    limit: Upload.IQDB_LIMIT,
    search: {
      media_asset_id: media_asset_id,
      similarity: Upload.IQDB_MIN_SIMILARITY,
      high_similarity: Upload.IQDB_HIGH_SIMILARITY
    }
  });
}

$(function() {
  Upload.initialize_all();
});

export default Upload
