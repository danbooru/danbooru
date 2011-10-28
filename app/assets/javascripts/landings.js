$(function() {
  $("#c-landings div.data").each(function(i, div) {
    var $div = $(div);
    var $image = $div.prev();
    
    $div.width($image.width() - 10).height($image.height() - 10).offset({top: $image.position().top, left: $image.position().left});
  });
});
