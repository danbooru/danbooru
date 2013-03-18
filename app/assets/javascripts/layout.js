$(function() {
  var offset = $("aside#sidebar").offset().top + $("aside#sidebar").height();
  $("#page-footer").css({"position": "absolute", "top": offset, "width": "100%", "height": "5em"});
});
