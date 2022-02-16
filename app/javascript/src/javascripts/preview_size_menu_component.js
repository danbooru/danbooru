import Cookie from './cookie';

export default class PreviewSizeMenuComponent {
  static initialize() {
    $(document).on("click.danbooru", ".preview-size-menu .popup-menu-content a", e => PreviewSizeMenuComponent.onClick(e));
  }

  static onClick(e) {
    let url = new URL($(e.target).get(0).href);
    let size = url.searchParams.get("size");

    Cookie.put("post_preview_size", size);
    url.searchParams.delete("size");
    location.replace(url);

    e.preventDefault();
  }
}

$(PreviewSizeMenuComponent.initialize);
