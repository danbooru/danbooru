import CurrentUser from './current_user'
import Utility from './utility'
import Hammer from 'hammerjs'
import Cookie from './cookie'
import Note from './notes'
import Ugoira from './ugoira'
import Rails from '@rails/ujs'

let Post = {};

Post.pending_update_count = 0;
Post.SWIPE_THRESHOLD = 60;
Post.SWIPE_VELOCITY = 0.6;
Post.MAX_RECOMMENDATIONS = 45; // 3 rows of 9 posts at 1920x1080.
Post.LOW_TAG_COUNT = 10;
Post.HIGH_TAG_COUNT = 20;
Post.EDIT_DIALOG_WIDTH = 640;
Post.EDIT_DIALOG_MIN_HEIGHT = 320;

// Variablen für das Endlos-Scrolling
Post.pageBreak = false;
Post.scrollBuffer = 600;
Post.timeToFailure = 15000;
Post.nextPage = null;
Post.mainTable = null;
Post.mainParent = null;
Post.pending = false;
Post.timeout = null;
Post.iframe = null;
Post.originalPage = window.location.href;
Post.lastScrollPosition = 0;
Post.pageHistory = [];

Post.initialize_all = function() {

  if ($("#c-posts").length) {
    this.initialize_saved_searches();
  }

  // Überprüfen, ob wir uns auf der Hauptseite oder auf der Post-Seite befinden.
  let isMainPage = $("#a-index").length > 0;

  // Bedingung ändern, um Gesten auf der Hauptseite und der Post-Seite zu initialisieren.
  if ($("#c-posts").length && (isMainPage || $("#a-show").length)) {
    this.initialize_endlessscroll();
    this.initialize_excerpt();
    this.initialize_gestures();
    this.initialize_post_preview_size_menu();
    this.initialize_post_preview_options_menu();
  }

  if ($("#c-posts").length && $("#a-show").length) {
    this.initialize_links();
    this.initialize_post_relationship_previews();
    this.initialize_post_sections();
    this.initialize_post_image_resize_links();
    this.initialize_recommended();
    this.initialize_ugoira_player();
  }

  if ($("#c-posts #a-show, #c-uploads #a-show").length) {
    this.initialize_edit_dialog();
  }

  this.initialize_ruffle_player();

  $(window).on('danbooru:initialize_saved_seraches', () => {
    Post.initialize_saved_searches();
  });
}

Post.initialize_endlessscroll = function() {
  {
    //Stop if inside an iframe
    if( window != window.top || Post.scrollBuffer == 0 )
      return;

    //Stop if no "table"
    Post.mainTable = this.getMainTable(document);
    if( !Post.mainTable )
      return;

    //Stop if no paginator
    var paginator = this.getPaginator(document);
    if( !paginator )
      return;

    //Stop if no more pages
    Post.nextPage = this.getNextPage(paginator);
    if( !Post.nextPage )
      return;

    // Initialisieren Sie die pageHistory für die aktuelle Seite
    let currentPosts = Post.mainTable.querySelectorAll("article");
    let currentPostIds = Array.from(currentPosts).map(post => post.getAttribute("data-id"));

    Post.pageHistory.push({
        url: Post.originalPage,
        paginator: Post.getPaginator(document),
        posts: currentPostIds
    });
    
    //Hide the blacklist sidebar, since this script breaks the tag totals and post unhiding.
    var sidebar = document.getElementById("blacklisted-sidebar");
    if( sidebar )
      sidebar.style.display = "none";

    //Other important variables:
    Post.scrollBuffer += window.innerHeight;
    Post.mainParent = Post.mainTable.parentNode;
    Post.pending = false;
    
    Post.iframe = document.createElement("iframe");
    Post.iframe.width = Post.iframe.height = 0;
    Post.iframe.style.visibility = "hidden";
    document.body.appendChild(Post.iframe);

    //Slight delay so that Danbooru's initialize_edit_links() has time to hide all the edit boxes on the Comment index
    Post.iframe.addEventListener("load", function(e){ setTimeout( Post.appendNewContent, 100 ); }, false);
    
    var content = Post.mainTable.innerHTML;
    var regex = /<div id="posts">[\s\S]*?<p>\s*No posts found\.\s*<\/p>[\s\S]*?<\/div>/;
    
    //Stop if empty page
    if (regex.test(content)) {
      return;
    }

    //Add copy of paginator to the top
    Post.mainParent.insertBefore( paginator.cloneNode(true), Post.mainParent.firstChild );

    // Ensure the top paginator is always visible
    let topPaginator = document.querySelector("#paginator:first-child");
    if (topPaginator) {
        topPaginator.style.display = "block";
    }

    if(Post.pageBreak) {
      //Reposition bottom paginator and add horizontal break
      Post.mainTable.parentNode.insertBefore( document.createElement("hr"), Post.mainTable.nextSibling );
      Post.mainTable.parentNode.insertBefore( paginator, Post.mainTable.nextSibling );
    }
    
    //Listen for scroll events
    let postsContainer = document.querySelector(".posts-container");
    if (postsContainer) {
        postsContainer.addEventListener("scroll", function() {
            Post.testScrollPosition();
            Post.updatePaginatorBasedOnScroll(); // Hinzugefügt
        }, false);
    }
    Post.testScrollPosition();
  }
}

Post.getMainTable = function(source) {
	var xpath =
	[
		 ".//div[contains(@class,'posts-container') or contains(@class,'media-assets-container')]"   // Danbooru (posts, ai_tags, uploads)
		,".//div[@id='a-index']/table[not(contains(@class,'search'))]"	// Danbooru (/forum_topics, ...), take care that this doesn't catch comments containing tables
		,".//div[@id='a-index']"						// Danbooru (/comments, ...)
		
		,".//table[contains(@class,'highlight')]"		// large number of pages
		,".//div[contains(@id,'comment-list')]/div/.."	// comment index
		,".//*[not(contains(@id,'popular'))]/span[contains(@class,'thumb')]/a/../.."	// post/index, pool/show, note/index
		,".//li/div/a[contains(@class,'thumb')]/../../.."	// post/index, note/index
		,".//div[@id='content']//table/tbody/tr[contains(@class,'even')]/../.."	// user/index, wiki/history
		,".//div[@id='content']/div/table"				// 3dbooru user records
		,".//div[@id='forum']"							// forum/show
	];

  for (var i = 0; i < xpath.length; i++) {
      let evaluatorFunction = (function(query) {
          return function(src) {
              return new XPathEvaluator().evaluate(query, src, null, XPathResult.FIRST_ORDERED_NODE_TYPE, null).singleNodeValue;
          };
      })(xpath[i]);

      var result = evaluatorFunction(source);
      if (result) {
          return result;
      }
  }

  return null;
};

Post.getPaginator = function(source) {
	var pager = new XPathEvaluator().evaluate("descendant-or-self::div[@id='paginator' or contains(@class,'paginator') or @id='paginater']", source, null, XPathResult.FIRST_ORDERED_NODE_TYPE, null).singleNodeValue;
	
	// Need clear:none to prevent the 2nd page from being pushed to below the sidebar on the Post index... but we don't want this when viewing a specific pool,
	// because then the paginator is shoved to the right of the last images on a page.  Other sites have issues with clear:none as well, like //yande.re/post.
	if( pager && location.host.indexOf("donmai.") >= 0 && document.getElementById("sidebar") )
		pager.style.clear = "none";
	
	return pager;
};

Post.getNextPage = function(source) {
	let page = Post.getPaginator(source);
	if( page )
		page = new XPathEvaluator().evaluate(".//a[@alt='next' or @rel='next' or contains(text(),'>') or contains(text(),'Next')]", page, null, XPathResult.FIRST_ORDERED_NODE_TYPE, null).singleNodeValue;
    
	return( page && page.href );
};

Post.testScrollPosition = function() {
  let postsContainer = document.querySelector(".posts-container");
    
  if (!postsContainer || !Post.nextPage) {
      return;
  }

  let containerHeight = postsContainer.clientHeight;
  let scrollHeight = postsContainer.scrollHeight;
  let scrollTop = postsContainer.scrollTop;

  if (!Post.pending && (scrollTop + containerHeight + Post.scrollBuffer > scrollHeight)) {
      Post.pending = true;
      Post.timeout = setTimeout(function(){
          Post.pending = false;
          Post.testScrollPosition();
      }, Post.timeToFailure);
      Post.iframe.contentDocument.location.replace(Post.nextPage);
  }
};

Post.setPaginator = function(paginator) {
  let currentPaginator = Post.getPaginator(document);
  if (currentPaginator && paginator) {
      currentPaginator.parentNode.replaceChild(paginator, currentPaginator);
  }
};

Post.updatePaginatorBasedOnScroll = function() {
  let postsContainer = document.querySelector(".posts-container");
  
  if (!postsContainer) return;
  
  let currentScrollPosition = postsContainer.scrollTop;
  let containerHeight = postsContainer.clientHeight;

  // Bestimmen Sie den aktuellen sichtbaren Post
  let posts = postsContainer.querySelectorAll("article");
  let currentPost = null;

  for (let post of posts) {
    let postPosition = post.offsetTop;
    if (postPosition >= currentScrollPosition && postPosition < currentScrollPosition + containerHeight) {
      currentPost = post;
      break;
    }
  }

  // Bestimmen Sie die Seite des aktuellen sichtbaren Posts
  if (currentPost) {
    let postId = currentPost.getAttribute("data-id");

    let foundPage = false;
    for (let page of Post.pageHistory) {
        if (page.posts.includes(postId)) {
            foundPage = true;
            Post.setPaginator(page.paginator);
            break;
        }
      }
    }

  // Speichern Sie die aktuelle Scroll-Position für das nächste Mal.
  Post.lastScrollPosition = currentScrollPosition;
};

Post.appendNewContent = function() {
    clearTimeout(Post.timeout);
    if( Post.nextPage.indexOf(Post.iframe.contentDocument.location.href) < 0 ) {
        setTimeout( function(){ Post.pending = false; }, 1000 );
        return;
    }

    var sourcePaginator = document.adoptNode( Post.getPaginator(Post.iframe.contentDocument) );
    var nextElem, deleteMe, source = document.adoptNode( Post.getMainTable(Post.iframe.contentDocument) );

    var content = source.innerHTML;
    var regex = /<div id="posts">[\s\S]*?<p>\s*No posts found\.\s*<\/p>[\s\S]*?<\/div>/;

    if( regex.test(content) )
        Post.nextPage = null;
    else {
        Post.nextPage = Post.getNextPage(sourcePaginator);

        let existingPosts = Post.mainTable.querySelectorAll("article");
        existingPosts.forEach(post => post.setAttribute('data-existing', 'true'));

        if( Post.pageBreak )
            Post.mainParent.appendChild(source);
        else {
            var rems = source.querySelectorAll("h2, h3, h4, thead, tfood");
            for( var i = 0; i < rems.length; i++ )
                rems[i].style.display = "none";
            
            var fragment = document.createDocumentFragment();
            while( (nextElem = source.firstChild) )
                fragment.appendChild(nextElem);
            Post.mainTable.appendChild(fragment);
        }
    }

	if( Post.pageBreak && Post.nextPage )
		Post.mainParent.appendChild( document.createElement("hr") );
	
	//Clear the pending request marker and check position again
	Post.pending = false;
	Post.testScrollPosition();

  let posts = Post.mainTable.querySelectorAll("article:not([data-existing='true'])");
  let postIds = Array.from(posts).map(post => post.getAttribute("data-id"));

  // Überprüfen Sie, ob diese Beiträge bereits in der Historie sind
  let existingPage = Post.pageHistory.find(page => page.posts.some(id => postIds.includes(id)));

  if (!existingPage) {
      Post.pageHistory.push({
          url: Post.originalPage,
          paginator: sourcePaginator,
          posts: postIds
      });
  }
};

Post.initialize_gestures = function() {
  console.log("initialize_gestures called");

  if (CurrentUser.data("disable-mobile-gestures")) {
    return;
  }
  var $body = $("body");
  if ($body.data("hammer")) {
    return;
  }
  if (!Utility.test_max_width(660)) {
    return;
  }
  $(".image-container").css({overflow: "visible"});

  // Erkennen, ob wir uns auf der Hauptseite oder auf der Post-Seite befinden.
  let isMainPage = $("#a-index").length;
  
  var hasPrev = isMainPage ? $(".paginator a[rel~=prev]").length : $("a[rel='nofollow prev']").length;
  var hasNext = isMainPage ? $(".paginator a[rel~=next]").length : $("a[rel='nofollow next']").length;

  var hammer = new Hammer($body[0], {touchAction: 'pan-y', recognizers: [[Hammer.Swipe, { threshold: Post.SWIPE_THRESHOLD, velocity: Post.SWIPE_VELOCITY, direction: Hammer.DIRECTION_HORIZONTAL }]], inputClass: Hammer.TouchInput});
  $body.data("hammer", hammer);

  if (hasPrev) {
    hammer.on("swiperight", async function(e) {
      console.log("swiperight detected");
      $("body").css({"transition-timing-function": "ease", "transition-duration": "0.2s", "opacity": "0", "transform": "translateX(150%)"});
      await Utility.delay(200);
      Post.swipe_prev(e, isMainPage);
    });
  }

  if (hasNext) {
    hammer.on("swipeleft", async function(e) {
      console.log("swipeleft detected");
      $("body").css({"transition-timing-function": "ease", "transition-duration": "0.2s", "opacity": "0", "transform": "translateX(-150%)"});
      await Utility.delay(200);
      Post.swipe_next(e, isMainPage);
    });
  }
}

Post.swipe_prev = function(e, isMainPage) {
  var linkSelector;
  if (isMainPage) {
    linkSelector = $(".paginator a[rel~=prev]").length ? ".paginator a[rel~=prev]" : "a[rel='prev']";
  } else {
    linkSelector = "a[rel='nofollow prev']";
  }
  
  if ($(linkSelector).length) {
    location.href = $(linkSelector).attr("href");
  }

  e.preventDefault();
}

Post.swipe_next = function(e, isMainPage) {
  var linkSelector;
  if (isMainPage) {
    linkSelector = $(".paginator a[rel~=next]").length ? ".paginator a[rel~=next]" : "a[rel='next']";
  } else {
    linkSelector = "a[rel='nofollow next']";
  }

  if ($(linkSelector).length) {
    location.href = $(linkSelector).attr("href");
  }

  e.preventDefault();
}

Post.initialize_edit_dialog = function() {
  $("#open-edit-dialog").show().on("click.danbooru", function(e) {
    Post.open_edit_dialog();
    e.preventDefault();
  });
}

Post.open_edit_dialog = function() {
  if ($("#edit-dialog").length === 1) {
    return;
  }

  $(document).trigger("danbooru:open-post-edit-dialog");

  $("#edit").show();
  $("#comments").hide();
  $("#post-sections li").removeClass("active");
  $("#post-edit-link").parent("li").addClass("active");
  $(".upload-container").css("display", "block");

  var $tag_string = $("#post_tag_string");
  $("body.c-uploads .docking-menu-tab").hide();

  var dialog = $("<div/>").attr("id", "edit-dialog");
  $("#form").appendTo(dialog);
  dialog.dialog({
    title: "Edit tags",
    width: Post.EDIT_DIALOG_WIDTH,
    height: Math.max($(window).height() * 0.50, Post.EDIT_DIALOG_MIN_HEIGHT),
    position: {
      my: "right top",
      at: "right-20 top+20",
      of: window
    },
    drag: function(e, ui) {
      $tag_string.data("uiAutocomplete").close();
    },
    close: Post.close_edit_dialog
  });
  dialog.dialog("widget").draggable("option", "containment", "none");

  var pin_button = $("<button/>").button({icons: {primary: "ui-icon-pin-w"}, label: "pin", text: false});
  pin_button.css({width: "20px", height: "20px", position: "absolute", right: "28.4px"});
  dialog.parent().children(".ui-dialog-titlebar").append(pin_button);
  pin_button.on("click.danbooru", function(e) {
    var dialog_widget = $('.ui-dialog:has(#edit-dialog)');
    var pos = dialog_widget.offset();

    if (dialog_widget.css("position") === "absolute") {
      pos.left -= $(window).scrollLeft();
      pos.top -= $(window).scrollTop();
      dialog_widget.offset(pos).css({ position: "fixed" });
      dialog.dialog("option", "resize", function() { dialog_widget.css({ position: "fixed" }); });

      pin_button.button("option", "icons", {primary: "ui-icon-pin-s"});
    } else {
      pos.left += $(window).scrollLeft();
      pos.top += $(window).scrollTop();
      dialog_widget.offset(pos).css({ position: "absolute" });
      dialog.dialog("option", "resize", function() { /* do nothing */ });

      pin_button.button("option", "icons", {primary: "ui-icon-pin-w"});
    }
  });

  dialog.parent().mouseout(function(e) {
    dialog.parent().css({"opacity": 0.6, "transition": "opacity .4s ease"});
  }).mouseover(function(e) {
    dialog.parent().css({"opacity": 1, "transition": "opacity .2s ease"});
  });

  $tag_string.css({"resize": "none", "width": "100%"});
  $tag_string.focus().selectEnd();
}

Post.close_edit_dialog = function(e, ui) {
  $("#form").appendTo($("#c-posts #edit, .upload-edit-container"));
  $(".upload-container").css("display", "");
  $("#edit-dialog").remove();
  var $tag_string = $("#post_tag_string");
  $("div.input").has($tag_string).prevAll().show();
  $("body.c-uploads .docking-menu-tab").show();
  $tag_string.css({"resize": "", "width": ""});
  $(document).trigger("danbooru:close-post-edit-dialog");
}

Post.initialize_links = function() {
  $("#copy-notes").on("click.danbooru", function(e) {
    var current_post_id = $("meta[name=post-id]").attr("content");
    var other_post_id = parseInt(prompt("Enter the ID of the post to copy all notes to:"), 10);

    if (other_post_id !== null) {
      $.ajax("/posts/" + current_post_id + "/copy_notes", {
        type: "PUT",
        data: {
          other_post_id: other_post_id
        },
        success: function(data) {
          Utility.notice("Successfully copied notes to <a href='" + other_post_id + "'>post #" + other_post_id + "</a>");
        },
        error: function(data) {
          if (data.status === 404) {
            Utility.error("Error: Invalid destination post");
          } else if (data.responseJSON && data.responseJSON.reason) {
            Utility.error("Error: " + data.responseJSON.reason);
          } else {
            Utility.error("There was an error copying notes to <a href='" + other_post_id + "'>post #" + other_post_id + "</a>");
          }
        }
      });
    }

    e.preventDefault();
  });
}

Post.initialize_post_relationship_previews = function() {
  var current_post_id = $("meta[name=post-id]").attr("content");
  $("[id=post_" + current_post_id + "]").addClass("current-post");

  if (Cookie.get("show-relationship-previews") === "0") {
    this.toggle_relationship_preview($("#has-children-relationship-preview"), $("#has-children-relationship-preview-link"));
    this.toggle_relationship_preview($("#has-parent-relationship-preview"), $("#has-parent-relationship-preview-link"));
  }

  $("#has-children-relationship-preview-link").on("click.danbooru", function(e) {
    Post.toggle_relationship_preview($("#has-children-relationship-preview"), $(this));
    e.preventDefault();
  });

  $("#has-parent-relationship-preview-link").on("click.danbooru", function(e) {
    Post.toggle_relationship_preview($("#has-parent-relationship-preview"), $(this));
    e.preventDefault();
  });
}

Post.toggle_relationship_preview = function(preview, preview_link) {
  preview.toggle();
  if (preview.is(":visible")) {
    preview_link.html("&laquo; hide");
    Cookie.put("show-relationship-previews", "1");
  } else {
    preview_link.html("show &raquo;");
    Cookie.put("show-relationship-previews", "0");
  }
}

Post.initialize_post_preview_size_menu = function() {
  $(document).on("click.danbooru", ".post-preview-size-menu .popup-menu-content a", (e) => {
    let url = new URL($(e.target).get(0).href);
    let size = url.searchParams.get("size");

    Cookie.put("post_preview_size", size);
    url.searchParams.delete("size");
    location.replace(url);

    e.preventDefault();
  });
}

Post.initialize_post_preview_options_menu = function() {
  $(document).on("click.danbooru", "a.post-preview-show-votes", (e) => {
    Cookie.put("post_preview_show_votes", "true");
    location.reload();
    e.preventDefault();
  });

  $(document).on("click.danbooru", "a.post-preview-hide-votes", (e) => {
    Cookie.put("post_preview_show_votes", "false");
    location.reload();
    e.preventDefault();
  });
}

Post.view_original = function(e = null) {
  if (Utility.test_max_width(660)) {
    // Do the default behavior (navigate to image)
    return;
  }

  var $image = $("#image");
  var $post = $(".image-container");
  $image.attr("src", $(".image-view-original-link").attr("href"));
  $image.css("filter", "blur(8px)");
  $image.width($post.data("width"));
  $image.height($post.data("height"));
  $image.on("load.danbooru", function() {
    $image.css("animation", "sharpen 0.5s forwards");
  });
  Note.Box.scale_all();
  $("body").attr("data-post-current-image-size", "original");
  e?.preventDefault();
}

Post.view_large = function(e = null) {
  if (Utility.test_max_width(660)) {
    // Do the default behavior (navigate to image)
    return;
  }

  var $image = $("#image");
  var $post = $(".image-container");
  $image.attr("src", $(".image-view-large-link").attr("href"));
  $image.css("filter", "blur(8px)");
  $image.width($post.data("large-width"));
  $image.height($post.data("large-height"));
  $image.on("load.danbooru", function() {
    $image.css("animation", "sharpen 0.5s forwards");
  });
  Note.Box.scale_all();
  $("body").attr("data-post-current-image-size", "large");
  e?.preventDefault();
}

Post.toggle_fit_window = function(e) {
  $("#image").toggleClass("fit-width");
  Note.Box.scale_all();
  Post.resize_ugoira_controls();
  e.preventDefault();
};

Post.initialize_post_image_resize_links = function() {
  $(document).on("click.danbooru", ".image-view-original-link", Post.view_original);
  $(document).on("click.danbooru", ".image-view-large-link", Post.view_large);
  $(document).on("click.danbooru", ".image-resize-to-window-link", Post.toggle_fit_window);

  if ($("#image-resize-notice").length) {
    Utility.keydown("v", "resize", function(e) {
      if ($("body").attr("data-post-current-image-size") === "large") {
        Post.view_original();
      } else {
        Post.view_large();
      }
    });
  }
}

Post.initialize_excerpt = function() {
  $("#excerpt").hide();

  $("#show-posts-link").on("click.danbooru", function(e) {
    $("#show-posts-link").addClass("active");
    $("#show-excerpt-link").removeClass("active");
    $("#posts").show();
    $("#excerpt").hide();
    e.preventDefault();
  });

  $("#show-excerpt-link").on("click.danbooru", function(e) {
    if ($(this).hasClass("active")) {
      return;
    }
    $("#show-posts-link").removeClass("active");
    $("#show-excerpt-link").addClass("active");
    $("#posts").hide();
    $("#excerpt").show();
    e.preventDefault();
  });

  if (!$(".post-preview").length && /No posts found/.test($("#posts").html())) {
    $("#show-excerpt-link").click();
  }
}

Post.initialize_post_sections = function() {
  $("#post-sections li a,#side-edit-link").on("click.danbooru", function(e) {
    if (e.target.hash === "#comments") {
      $("#comments").show();
      $("#edit").hide();
      $("#recommended").hide();
    } else if (e.target.hash === "#edit") {
      $("#edit").show();
      $("#comments").hide();
      $("#post_tag_string").focus().selectEnd();
      $("#recommended").hide();
      $(document).trigger("danbooru:open-post-edit-tab");
    } else if (e.target.hash === "#recommended") {
      $("#comments").hide();
      $("#edit").hide();
      $("#recommended").show();
      $.get("/recommended_posts.js", { search: { post_id: Utility.meta("post-id") }, limit: Post.MAX_RECOMMENDATIONS });
    } else {
      $("#edit").hide();
      $("#comments").hide();
      $("#recommended").hide();
    }

    $("#post-sections li").removeClass("active");
    $(e.target).parent("li").addClass("active");
    e.preventDefault();
  });
}

Post.initialize_ugoira_player = function() {
  if ($("#ugoira-controls").length) {
    let frame_delays = $("#image").data("ugoira-frame-delays");
    let file_url = $(".image-container").data("file-url");

    Ugoira.create_player(frame_delays, file_url);
    $(window).on("resize.danbooru.ugoira_scale", Post.resize_ugoira_controls);
  }
};

Post.initialize_ruffle_player = function() {
  let $container = $(".ruffle-container[data-swf]");

  if ($container.length) {
    let ruffle = window.RufflePlayer.newest();
    let player = ruffle.createPlayer();
    let src = $container.attr("data-swf");
    $container.get(0).appendChild(player);
    player.load(src);
  }
};

Post.resize_ugoira_controls = function() {
  var $img = $("#image");
  var width = Math.max($img.width(), 350);
  $("#ugoira-control-panel").css("width", width);
  $("#seek-slider").css("width", width - 81);
}

Post.show_pending_update_notice = function() {
  if (Post.pending_update_count === 0) {
    Utility.notice("Posts updated");
  } else {
    Utility.notice(`Updating posts (${Post.pending_update_count} pending)...`, true);
  }
}

Post.tag = function(post_id, tags) {
  tags ??= "";
  const tag_string = (Array.isArray(tags) ? tags.join(" ") : String(tags));
  Post.update(post_id, "tag-script", { post: { old_tag_string: "", tag_string: tag_string }});
}

Post.update = async function(post_id, mode, params) {
  try {
    Post.pending_update_count += 1;
    Post.show_pending_update_notice()

    let urlParams = new URLSearchParams(window.location.search);
    let show_votes = urlParams.get("show_votes");
    let size = urlParams.get("size");

    await $.ajax({ type: "PUT", url: `/posts/${post_id}.js`, data: { mode, show_votes, size, ...params }});

    Post.pending_update_count -= 1;
    Post.show_pending_update_notice();
  } catch (err) {
    Post.pending_update_count -= 1;
  }
}

Post.initialize_saved_searches = function() {
  $("#save-search-dialog").dialog({
    width: 700,
    modal: true,
    autoOpen: false,
    buttons: {
      "Submit": function() {
        let form = $("#save-search-dialog form").get(0);
        Rails.fire(form, "submit");
        $(this).dialog("close");
      },
      "Cancel": function() {
        $(this).dialog("close");
      }
    }
  });

  $("#save-search").on("click.danbooru", function(e) {
    $("#save-search-dialog #saved_search_query").val($("#tags").val());

    if (CurrentUser.data("disable-categorized-saved-searches") === false) {
      $("#save-search-dialog").dialog("open");
    } else {
      $.post(
        "/saved_searches.js",
        {
          "saved_search": {
            "query": $("#tags").val()
          }
        }
      );
    }

    e.preventDefault();
  });
}

Post.initialize_recommended = function() {
  $(document).on("click.danbooru", ".post-preview .more-recommended-posts", async function (event) {
    event.preventDefault();

    let post_id = $(this).parents(".post-preview").data("id");
    $("#recommended").addClass("loading-recommended-posts");
    await $.get("/recommended_posts.js", { search: { post_id: post_id }, limit: Post.MAX_RECOMMENDATIONS });
    $("#recommended").removeClass("loading-recommended-posts");
  });
};

$(document).ready(function() {
  Post.initialize_all();
});

export default Post