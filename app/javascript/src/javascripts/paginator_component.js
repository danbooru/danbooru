export default class PaginatorComponent {
  static initialize() {
    $(document).on("click.danbooru", ".paginator-ellipsis", e => PaginatorComponent.onClickEllipsis(e));
  }

  static onClickEllipsis(e) {
    e.preventDefault();

    let page = prompt("Jump to page:");
    if (!page) {
      return;
    }

    let url = new URL(location.href);
    url.searchParams.set("page", page);
    location.href = url.toString();
  }
}

$(PaginatorComponent.initialize);
