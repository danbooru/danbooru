import { delay } from "./utility";

export default class UploadMediaAsset {
  static async loadAssets() {
    while ($(".upload-media-asset-loading").length) {
      let ids = $(".upload-media-asset-loading").map((i, el) => $(el).attr("data-id")).toArray().join(",");
      let size = $(".upload-media-asset-gallery").attr("data-size");
      $.get("/upload_media_assets.js", { search: { status: "active failed", id: ids }, size: size });
      await delay(250);
    }
  }
}

$(function() {
  UploadMediaAsset.loadAssets();
});
