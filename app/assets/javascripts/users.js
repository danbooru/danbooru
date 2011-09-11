$(function() {
  $("div#c-users div#a-new footer.nav-links a").click(function(event) {
    $("div#c-users div#a-new > div").hide();
    $(event.target.hash).show();
  });
  
  if (Danbooru.meta("errors")) {
    // $("#p1").hide();
    // $("#notice").hide();
  } else {
    // $("#p2").hide();
  }
});
