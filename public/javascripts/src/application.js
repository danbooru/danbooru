// Cookie.setup();

$(document).ready(function() {
	// $("#hide-upgrade-account-link").click(function() {
	// 	$("#upgrade-account").hide();
	// 	Cookie.put('hide-upgrade-account', '1', 7);
	// });
	
	// Comment listing
	$(".comment-section form").hide();
	$(".comment-section input.expand-comment-response").click(function() {
		var post_id = $(this).closest(".comment-section").attr("data-post-id");
		$(".comment-section[data-post-id=" + post_id + "] form").show();
		$(this).hide();
	})

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

// ContextMenu

Danbooru.ContextMenu = {};

Danbooru.ContextMenu.add_icon = function() {
  $("menu[type=context] > li").append('<img src="/images/arrow2_s.png">');        
}

Danbooru.ContextMenu.toggle_icon = function(li) {
  if (li == null) {
    $("menu[type=context] > li > img").attr("src", "/images/arrow2_s.png");
  } else {
    $(li).find("img").attr("src", function() {
      if (this.src.match(/_n/)) {
        return "/images/arrow2_s.png";              
      } else {
        return "/images/arrow2_n.png";
      }
    });
  }
}

Danbooru.ContextMenu.setup = function() {
  $("menu[type=context] li").hover(
    function() {$(this).css({"background-color": "#F6F6F6"})},
    function() {$(this).css({"background-color": "#EEE"})}
  );
  
  this.add_icon();
  
  $("menu[type=context] > li").click(function(e) {
    $(this).parent().find("ul").toggle();
    e.stopPropagation();
    Danbooru.ContextMenu.toggle_icon(this);
  });
  
  $(document).click(function() {
    $("menu[type=context] > ul").hide();
    Danbooru.ContextMenu.toggle_icon();
  });
  
  $("menu[type=context] > ul > li").click(function(element) {
    $(this).closest("ul").toggle();
    var text = $(this).text()
    var menu = $(this).closest("menu");
    menu.children("li").text(text);
    if (menu.attr("data-update-field-id")) {
      $("#" + menu.attr("data-update-field-id")).val(text);
      Danbooru.ContextMenu.add_icon();
    }
    if (menu.attr("data-submit-on-change") == "true") {
      menu.closest("form").submit();
    }
  });
}

$(document).ready(function() {
  Danbooru.ContextMenu.setup();
});
