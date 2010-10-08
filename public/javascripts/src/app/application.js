$(document).ready(function() {
  Cookie.setup();
  
	// $("#hide-upgrade-account-link").click(function() {
	// 	$("#upgrade-account").hide();
	// 	Cookie.put('hide-upgrade-account', '1', 7);
	// });

  // Style button spans
	
	// Comment listing
	$(".comment-section form").hide();
	$(".comment-section input.expand-comment-response").click(function() {
		var post_id = $(this).closest(".comment-section").attr("data-post-id");
		$(".comment-section[data-post-id=" + post_id + "] form").show();
		$(this).hide();
	});

  // Image resize sidebar
  $("#resize-links").hide();

  $("#resize-links a").click(function(e) {
    var image = $("#image");
    var target = $(e.target);
    image.attr("src", target.attr("data-src"));
    image.attr("width", target.attr("data-width"));
    image.attr("height", target.attr("data-height"));
    e.preventDefault();
  }); 
	
	$("#resize-link a").click(function(e) {
	  $("#resize-links").toggle();
	  e.preventDefault();
	});
});


var Danbooru = {};
