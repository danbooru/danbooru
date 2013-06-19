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
    $(document).bind("keypress", "d", Danbooru.Paginator.next_page);
    $(document).bind("keypress", "a", Danbooru.Paginator.prev_page);
  }
});

