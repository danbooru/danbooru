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
});

var Danbooru = {};
