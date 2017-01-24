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
  if ($(".paginator").length) {
    Danbooru.keydown("d right", "next_page", Danbooru.Paginator.next_page);
    Danbooru.keydown("a left", "prev_page", Danbooru.Paginator.prev_page);
  }
});

