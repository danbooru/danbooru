(function() {
  Danbooru.Paginator = {};

  Danbooru.Paginator.next_page = function() {
    var href = $(".paginator a[rel=next]").attr("href");
    if (href) {
      window.location = href;
    }
  }

  Danbooru.Paginator.prev_page = function() {
    var href = $(".paginator a[rel=prev]").attr("href");
    if (href) {
      window.location = href;
    }
  }
})();

$(function() {
  if ($(".paginator").length && (Danbooru.meta("enable-js-navigation") === "true")) {
    $(document).bind("keydown", "d", Danbooru.Paginator.next_page);
    $(document).bind("keydown", "a", Danbooru.Paginator.prev_page);
  }
});

