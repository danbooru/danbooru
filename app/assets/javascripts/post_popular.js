(function() {
  Danbooru.PostPopular = {};

  Danbooru.PostPopular.nav_prev = function() {
    if ($("#popular-nav-links").length) {
      var href = $("#popular-nav-links a[rel=prev]").attr("href");
      if (href) {
        location.href = href;
      }
    }
  }

  Danbooru.PostPopular.nav_next = function() {
    if ($("#popular-nav-links").length) {
      var href = $("#popular-nav-links a[rel=next]").attr("href");
      if (href) {
        location.href = href;
      }
    }
  }

  Danbooru.PostPopular.initialize_all = function() {
    if ($("#c-explore-posts").length) {
      if (Danbooru.meta("enable-js-navigation") === "true") {
        $(document).bind("keypress", "a", function(e) {
          Danbooru.PostPopular.nav_prev();
          e.preventDefault();
        });

        $(document).bind("keypress", "d", function(e) {
          Danbooru.PostPopular.nav_next();
          e.preventDefault();
        });
      }
    }
  }
})();

$(document).ready(function() {
  Danbooru.PostPopular.initialize_all();
});