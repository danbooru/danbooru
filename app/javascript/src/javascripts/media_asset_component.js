export default class MediaAssetComponent {
  static initialize() {
    $(".media-asset-component").toArray().forEach(element => {
      new MediaAssetComponent(element);
    });
  }

  constructor(element) {
    this.$component = $(element);
    this.$container = this.$component.find(".media-asset-container");
    this.$image = this.$component.find(".media-asset-image");
    this.$zoomLevel = this.$component.find(".media-asset-zoom-level");

    if (this.$component.attr("data-dynamic-height") === "true") {
      this.updateHeight();
      $(window).on("scroll.danbooru", e => this.updateHeight());
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
    if (this.canZoomOut) {
      this.$component.addClass("media-asset-component-fit-height media-asset-component-fit-width");
    } else if (this.canZoomHeight) {
      this.$component.removeClass("media-asset-component-fit-height");
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
    this.$component.css("--header-visible-height", Math.min(115, Math.max(0, this.$component.offset().top - $(window).scrollTop())) + "px");
  }

  get zoomLevel() {
    return this.$image.width() / Number(this.$image.attr("width"));
  }

  get canZoomIn() {
    return this.canZoomHeight;
  }

  get canZoomHeight() {
    return !this.isZoomed && this.$image.height() < this.$image.get(0).naturalHeight && Math.round(this.$image.width()) < Math.round(this.$component.width());
  }

  get canZoomOut() {
    return this.isZoomed;
  }

  get isZoomed() {
    return !this.$component.is(".media-asset-component-fit-height.media-asset-component-fit-width");
  }
}

$(MediaAssetComponent.initialize);
