(function() {
  Danbooru.PostPopular = {};

  Danbooru.PostPopular.nav_prev = function(e) {
    if ($("#popular-nav-links").length) {
      var href = $("#popular-nav-links a[rel=prev]").attr("href");
      if (href) {
        location.href = href;
      }
    }

    e.preventDefault();
  }

  Danbooru.PostPopular.nav_next = function(e) {
    if ($("#popular-nav-links").length) {
      var href = $("#popular-nav-links a[rel=next]").attr("href");
      if (href) {
        location.href = href;
      }
    }

    e.preventDefault();
  }

  Danbooru.PostPopular.initialize_all = function() {
    if ($("#c-explore-posts").length) {
      Danbooru.keydown("a left", "prev_page", Danbooru.PostPopular.nav_prev);
      Danbooru.keydown("d right", "next_page", Danbooru.PostPopular.nav_next);
    }
  }
})();

$(document).ready(function() {
  Danbooru.PostPopular.initialize_all();
});
