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
    await Utility.delay(1000);
  }
}

Upload.initialize_draggable_divider = function() {
  Upload.dragStartWidth = 0;

  $(".upload-divider").draggable({ axis: "x" });

  $(".upload-divider").on("dragstart", (event, ui) => {
    Upload.dragStartWidth = parseInt($(".upload-container").css("--edit-container-width"));
  });

  $(".upload-divider").on("drag", (event, ui) => {
    let minWidth = parseInt($(".upload-container").css("--min-edit-container-width"));
    let maxWidth = $(".upload-container").width() - minWidth;
    let width = clamp(Upload.dragStartWidth - ui.position.left, minWidth, maxWidth);

    $(".upload-container").css("--edit-container-width", width);
    Cookie.put("upload_edit_container_width", width);
    ui.position.left = 0;
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
