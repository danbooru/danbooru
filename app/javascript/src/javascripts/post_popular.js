import Utility from './utility'

let PostPopular = {};

PostPopular.nav_prev = function(e) {
  if ($("#popular-nav-links").length) {
    var href = $("#popular-nav-links a[rel=prev]").attr("href");
    if (href) {
      location.href = href;
    }
  }

  e.preventDefault();
}

PostPopular.nav_next = function(e) {
  if ($("#popular-nav-links").length) {
    var href = $("#popular-nav-links a[rel=next]").attr("href");
    if (href) {
      location.href = href;
    }
  }

  e.preventDefault();
}

PostPopular.initialize_all = function() {
  if ($("#c-explore-posts").length) {
    Utility.keydown("a left", "prev_page", PostPopular.nav_prev);
    Utility.keydown("d right", "next_page", PostPopular.nav_next);
  }
}

$(document).ready(function() {
  PostPopular.initialize_all();
});

export default PostPopular
