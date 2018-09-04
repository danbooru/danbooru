$(function() {
  $("#maintoggle").on("click.danbooru", function() {
    $('#nav').toggle();
    $('#maintoggle-on').toggle();
    $('#maintoggle-off').toggle();
  });
});
