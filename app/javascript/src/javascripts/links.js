let Links = {};

Links.initializeAll = function() {
  Links.initializeLinks("comment");
  Links.initializeLinks("forum_post");
}

Links.initializeLinks = function(type) {
  const re = new RegExp(`${type}s/(\\d+)$`);

  $(`a[href^='/${type}s/']`).on("click.danbooru", function(e) {
    // Use the link itself, not `e.target`, which may be an icon inside the link.
    const id = this.href.match(re)?.[1];
    const ref = `#${type}_${id}`;
    const el = $(ref);

    if (el.length) {
      e.preventDefault();
      // This doesn't update the selection properly.
      // history.replaceState(undefined, undefined, ref);
      location.hash = ref;
    }
  });
}

$(Links.initializeAll);

export default Links;
