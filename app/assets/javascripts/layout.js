$(function() {
  var $sidebar = $("#sidebar");
  var $content = $("#content");
  
  if (!$sidebar.length || !$content.length) {
    return;
  }
  
  var sidebar_offset = $sidebar.offset().top + $sidebar.height();
  var content_offset = $content.offset().top + $content.height();
  var offset = null;
  if (sidebar_offset > content_offset) {
    offset = sidebar_offset;
  } else {
    offset = content_offset;
  }
  $("#page-footer").css({"position": "absolute", "top": offset, "width": "100%", "height": "3em"});
});
