$(document).ready(function() {
  // $("#hide-upgrade-account-link").click(function() {
  //   $("#upgrade-account").hide();
  //   Cookie.put('hide-upgrade-account', '1', 7);
  // });
  
  // Table striping
  $("table.striped tbody tr:even").addClass("even");
  $("table.striped tbody tr:odd").addClass("odd");

  if ($("#site-map-link").length > 0) {
    // More link
    $("#site-map-link").click(function(e) {
      $("#more-links").toggle();
      e.preventDefault();
      e.stopPropagation();
    });

    $("#more-links").hide().offset({top: $("#site-map-link").offset().top, left: $("#site-map-link").offset().left + 10});  

    $(document).click(function(e) {
      $("#more-links").hide();
    });
  }
  
  // Ajax links
  $("a[data-remote=true]").click(function(e) {
    Danbooru.ajax_start(e.target);
  })
  
  $("a[data-remote=true]").ajaxComplete(function(e) {
    Danbooru.ajax_stop(e.target);
  })

  // TOS link
  if (!location.href.match(/terms_of_service/) && Danbooru.Cookie.get("tos") !== "1") {
    // Setting location.pathname in Safari doesn't work, so manually extract the domain.
    var domain = location.href.match(/^(http:\/\/[^\/]+)/)[0];
    location.href = domain + "/static/terms_of_service?url=" + location.href;
  }
  
  $("#tos-agree-link").click(function() {
    Danbooru.Cookie.put("tos", "1");
  })
});

var Danbooru = {};
