$(document).ready(function() {
  $("footer.nav-links a").click(function(event) {
    $("div.users div.new > div").hide();
    $(event.target.hash).show();
  });
  
  if (Danbooru.meta("errors")) {
    $("#p1").hide();
    $("#notice").hide();
  } else {
    $("#p2").hide();
  }
});
