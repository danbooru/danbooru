import Utility from './utility'

let Paginator = {};

Paginator.next_page = function() {
  var href = $(".paginator a[rel=next]").attr("href");
  if (href) {
    window.location = href;
  }
}

Paginator.prev_page = function() {
  var href = $(".paginator a[rel=prev]").attr("href");
  if (href) {
    window.location = href;
  }
}

$(function() {
  if ($(".paginator").length) {
    Utility.keydown("d right", "next_page", Paginator.next_page);
    Utility.keydown("a left", "prev_page", Paginator.prev_page);
  }
});

export default Paginator
