import Alpine from "@alpinejs/csp";
import AlpineCookieStorage from "./alpine_cookie_storage";
import Draggable from "./draggable";
import Notice from "./notice";
import Utility, { clamp } from "./utility";

export default class UploadPostComponent {
  IQDB_LIMIT = 5;
  IQDB_MIN_SIMILARITY = 25;
  IQDB_HIGH_SIMILARITY = 50;
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

    // Bound with jQuery instead of Alpine because the form can be moved out of the component into the edit dialog.
    this.$container.find(".upload-form").on("submit.danbooru", event => this.checkRating(event));
  }

  // Check that the rating button was pressed, or the tag string contains a rating.
  // Invalid ratings still go through, but are stopped server-side. The cost of reimplementing parsing logic
  // in javascript is not worth it when this covers the average user's case of forgetting to press the button.
  checkRating(event) {
    let $form = $(event.currentTarget);
    let ratingSelected = $form.find("input[name='post[rating]']:checked").length > 0;
    let tagString = $form.find("#post_tag_string").val();

    if (!ratingSelected && !/\brating:\S/i.test(tagString)) {
      event.preventDefault();
      event.stopPropagation(); // Stop rails-ujs from disabling the submit button.
      $form.find(".post_rating").addClass("field_with_errors");
      Notice.error("Rating not selected");
    }
  }

  showSimilarTab() {
    this.$container.find("a.tab.similar-tab").get(0).click();
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
    }).done(script => $.globalEval(script, { nonce: Utility.meta("csp-nonce") }));
  }
}

// The upload page. Used as `x-data="uploadPostComponent($el)"`.
Alpine.data("uploadPostComponent", (container) => ({
  upload: new UploadPostComponent(container),
}));
