import Cookie from "./cookie";
import Draggable from "./draggable";
import Notice from "./notice";
import RelatedTag from "./related_tag";
import { clamp, delay } from "./utility";

let Upload = {};

Upload.IQDB_LIMIT = 5;
Upload.IQDB_MIN_SIMILARITY = 50;
Upload.IQDB_HIGH_SIMILARITY = 70;
Upload.POLL_DELAY = 250;

Upload.initialize_all = function() {
  if ($("#c-uploads #a-show #p-single-asset-upload").length) {
    this.initialize_media_asset();
    this.initialize_draggable_divider();
  }

  Upload.loadAssets();
}

Upload.initialize_media_asset = async function() {
  const $upload_container = $(".upload-container");
  const upload_media_asset_id = $("input[name='upload_media_asset_id']").val();

  let upload_media_asset = {
    status: $upload_container.data("status"),
  }
  if (upload_media_asset.status !== "active" && upload_media_asset.status !== "failed") {
    while (upload_media_asset.status !== "active" && upload_media_asset.status !== "failed") {
      await delay(Upload.POLL_DELAY);
      upload_media_asset = await $.get(`/upload_media_assets/${upload_media_asset_id}.json?only=status,error,post[id]`);
    }

    if (upload_media_asset.status === "failed") {
      Notice.error(`Upload failed: ${upload_media_asset.error}.`);
    } else if (upload_media_asset.status === "active") {
      $("#related-tags-container").attr("data-media-asset-id", upload_media_asset.media_asset_id);
      $("input[name='media_asset_id']").val(upload_media_asset.media_asset_id);
      $.get(`/upload_media_assets/${upload_media_asset_id}.js`);
      RelatedTag.initialize_ai_tags();
    }
  }

  if (upload_media_asset.status === "active") {
    $("input[type='submit']").removeAttr("disabled");
    this.initialize_similar();

    while (!upload_media_asset.post) {
      await delay(Upload.POLL_DELAY);
      if (!document.hidden) {
        upload_media_asset = await $.get(`/upload_media_assets/${upload_media_asset_id}.json?only=status,error,post[id]`);
      }
    }

    const post_id = upload_media_asset.post.id;
    Notice.info(`Duplicate of <a href="/posts/${post_id}">post #${post_id}</a>`);
  }
}

Upload.loadAssets = async function() {
  while ($(".upload-media-asset-loading").length) {
    let ids = $(".upload-media-asset-loading").map((i, el) => $(el).attr("data-id")).toArray().join(",");
    let size = $(".upload-media-asset-gallery").attr("data-size");
    $.get("/upload_media_assets.js", { search: { status: "active failed", id: ids }, size: size });
    await delay(this.POLL_DELAY);
  }
}

Upload.initialize_draggable_divider = function() {
  Upload.draggable = new Draggable(".upload-divider");
  let currentPanelWidth = 0;
  let initialPanelWidth = 0;

  $(".upload-divider").on("drag:start", event => {
    initialPanelWidth = $(".upload-edit-container").width();
    currentPanelWidth = initialPanelWidth;
  });

  $(".upload-divider").on("drag:move", (event, moveEvent, drag) => {
    let reverseDrag = $(".upload-container").attr("data-dock") === "left";
    let dragOffset = drag.x * (reverseDrag ? -1 : 1);
    let minWidth = parseInt($(".upload-container").css("--min-edit-container-width"));
    let maxWidth = $(".upload-container").width() - minWidth;

    currentPanelWidth = clamp(initialPanelWidth - dragOffset, minWidth, maxWidth);
    $(".upload-container").css("--edit-container-width", currentPanelWidth);
  });

  $(".upload-divider").on("drag:stop", event => {
    Cookie.put("upload_edit_container_width", currentPanelWidth);
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
