export default class MediaAssetComponent {
  static initialize() {
    $(".media-asset-container").toArray().forEach(element => {
      new MediaAssetComponent(element);
    });
  }

  constructor(element) {
    this.$container = $(element);
    this.$component = this.$container.find(".media-asset-component");

    if (this.$container.attr("data-dynamic-height") === "true") {
      this.updateHeight();
      $(window).on("scroll.danbooru", element => {
        this.updateHeight();
      });
    }

    if (this.$image.length) {
      this.$image.on("click.danbooru", e => this.toggleFit());
      this.$image.on("load.danbooru", e => this.updateZoom());
      this.$image.on("load.danbooru", e => this.updateHeight());
      new ResizeObserver(() => this.updateZoom()).observe(this.$image.get(0));
      this.updateZoom();
    }
  }

  toggleFit() {
    if (this.canZoom) {
      this.$container.toggleClass("media-asset-container-fit-height");
    }

    this.updateZoom();
  }

  updateZoom() {
    this.$image.removeClass("cursor-zoom-in cursor-zoom-out");
    this.$zoomLevel.removeClass("hidden").text(`${Math.round(100 * this.zoomLevel)}%`);

    if (this.canZoomIn) {
      this.$image.addClass("cursor-zoom-in");
    } else if (this.canZoomOut) {
      this.$image.addClass("cursor-zoom-out");
    }
  }

  updateHeight() {
    // XXX 115 = header height (hardcoded to prevent height glitches as page loads)
    this.$container.css("--header-visible-height", Math.min(115, Math.max(0, this.$container.offset().top - $(window).scrollTop())) + "px");
  }

  get zoomLevel() {
    return this.$image.width() / Number(this.$image.attr("width"));
  }

  get canZoom() {
    return this.canZoomIn || this.canZoomOut;
  }

  get canZoomIn() {
    return !this.isZoomed && this.$image.height() < this.$image.get(0).naturalHeight && Math.round(this.$image.width()) < Math.round(this.$container.width());
  }

  get canZoomOut() {
    return this.isZoomed;
  }

  get isZoomed() {
    return !this.$container.is(".media-asset-container-fit-height");
  }

  get $image() {
    return this.$component.find(".media-asset-image");
  }

  get $zoomLevel() {
    return this.$component.find(".media-asset-zoom-level");
  }
}

$(MediaAssetComponent.initialize);
