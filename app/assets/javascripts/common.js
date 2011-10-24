$(document).ready(function() {
  // $("#hide-upgrade-account-link").click(function() {
  //   $("#upgrade-account").hide();
  //   Cookie.put('hide-upgrade-account', '1', 7);
  // });
  
  // Table striping
  $("table.striped tbody tr:even").addClass("even");
  $("table.striped tbody tr:odd").addClass("odd");

  // Comment listing
  $(".comment-section form").hide();
  $(".comment-section input.expand-comment-response").click(function() {
    var post_id = $(this).closest(".comment-section").data("post-id");
    $(".comment-section[data-post-id=" + post_id + "] form").show();
    $(this).hide();
  });
  
  // More link
  $("#site-map-link").click(function(e) {
    $("#more-links").toggle();
    e.preventDefault();
    e.stopPropagation();
  });
  $("#more-links").hide().offset({top: $("#site-map-link").offset().top + $("#site-map-link").height() + 10, left: $("#site-map-link").offset().left});  
  
  $(document).click(function(e) {
    $("#more-links").hide();
  });
  
  // Ajax links
  $("a[data-remote=true]").click(function(e) {
    Danbooru.ajax_start(e.target);
  })
  
  $("a[data-remote=true]").ajaxComplete(function(e) {
    Danbooru.ajax_stop(e.target);
  })

  // Image resize sidebar
  $("#resize-links").hide();

  $("#resize-links a").click(function(e) {
    var image = $("#image");
    var target = $(e.target);
    image.attr("src", target.data("src"));
    image.attr("width", target.data("width"));
    image.attr("height", target.data("height"));
    e.preventDefault();
  }); 
  
  $("#resize-link a").click(function(e) {
    $("#resize-links").toggle();
    e.preventDefault();
  });
  
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
