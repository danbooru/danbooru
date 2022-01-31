export default class MediaAssetComponent {
  static initialize() {
    $(".media-asset-component").toArray().forEach(element => {
      new MediaAssetComponent(element);
    });
  }

  constructor(element) {
    this.$component = $(element);

    if (this.$image.length) {
      this.$image.on("click.danbooru", e => this.toggleFit());
      new ResizeObserver(() => this.updateZoom()).observe(this.$image.get(0));
      this.updateZoom();
    }
  }

  toggleFit() {
    this.$component.toggleClass("fit-screen");
    this.updateZoom();
  }

  updateZoom() {
    this.$image.removeClass("cursor-zoom-in cursor-zoom-out");
    this.$zoomLevel.addClass("hidden").text(`${Math.round(100 * this.zoomLevel)}%`);

    if (this.isDownscaled) {
      this.$image.addClass("cursor-zoom-out");
      this.$zoomLevel.removeClass("hidden");
    } else if (this.isTooBig) {
      this.$image.addClass("cursor-zoom-in");
    }
  }

  get zoomLevel() {
    return this.$image.width() / Number(this.$image.attr("width"));
  }

  get isDownscaled() {
    return this.$image.width() < Number(this.$image.attr("width"));
  }

  get isTooBig() {
    return this.$image.width() > this.$component.width();
  }

  get $image() {
    return this.$component.find(".media-asset-image");
  }

  get $zoomLevel() {
    return this.$component.find(".media-asset-zoom-level");
  }
}

$(MediaAssetComponent.initialize);
