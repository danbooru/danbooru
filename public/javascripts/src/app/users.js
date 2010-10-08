$(document).ready(function() {
  $("footer.nav-links a").click(function(event) {
    $("div#users-new > div").hide();
    $(event.target.hash).show();
  });
  
  if ($("meta[name=errors]").attr("content")) {
    $("#p1").hide();
    $("#notice").hide();
  } else {
    $("#p2").hide();
  }
});
