import AlpineCookieStorage from "./alpine_cookie_storage";
import Draggable from "./draggable";
import { clamp } from "./utility";

export default class Upload {
  IQDB_LIMIT = 5;
  IQDB_MIN_SIMILARITY = 50;
  IQDB_HIGH_SIMILARITY = 70;
  MIN_EDIT_CONTAINER_WIDTH = 180;

  constructor(container) {
    this.$container = $(container);

    this.$divider = this.$container.find(".upload-divider");
    this.$editContainer = this.$container.find(".upload-edit-container");
    this.mediaAssetId = this.$container.data("media-asset-id");
    this.editContainerWidth = Alpine.$persist(this.$container.data("edit-container-width")).as("upload_edit_container_width").using(AlpineCookieStorage);
    this.dock = Alpine.$persist(this.$container.data("dock")).as("upload_edit_panel_dock").using(AlpineCookieStorage);
    this.draggable = new Draggable(this.$divider);
  }

  initialize() {
    this.initializeDraggable();
    this.initializeSimilar();
  }

  initializeDraggable() {
    let initialPanelWidth = 0;

    this.$divider.on("drag:start", event => {
      initialPanelWidth = this.$editContainer.width();
    });

    this.$divider.on("drag:move", (event, moveEvent, drag) => {
      let reverseDrag = this.dock === "left";
      let dragOffset = drag.x * (reverseDrag ? -1 : 1);
      let minWidth = this.MIN_EDIT_CONTAINER_WIDTH;
      let maxWidth = this.$container.width() - minWidth;

      this.editContainerWidth = clamp(initialPanelWidth - dragOffset, minWidth, maxWidth);
    });
  }

  initializeSimilar() {
    $.get("/iqdb_queries.js", {
      limit: this.IQDB_LIMIT,
      search: {
        media_asset_id: this.mediaAssetId,
        similarity: this.IQDB_MIN_SIMILARITY,
        high_similarity: this.IQDB_HIGH_SIMILARITY
      }
    });
  }
}
