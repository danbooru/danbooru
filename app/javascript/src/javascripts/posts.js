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
Post.EDIT_DIALOG_WIDTH = 720;

Post.initialize_all = function() {

  if ($("#c-posts").length) {
    this.initialize_saved_searches();
  }

  if ($("#c-posts").length && $("#a-index").length) {
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
    this.initialize_ruffle_player();
  }

  if ($("#c-posts #a-show, #c-uploads #a-show").length) {
    this.initialize_edit_dialog();
  }

  $(window).on('danbooru:initialize_saved_seraches', () => {
    Post.initialize_saved_searches();
  });
}

Post.initialize_gestures = function() {
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
  var hasPrev = $(".paginator a[rel~=prev]").length;
  var hasNext = $(".paginator a[rel~=next]").length;

  var hammer = new Hammer($body[0], {touchAction: 'pan-y', recognizers: [[Hammer.Swipe, { threshold: Post.SWIPE_THRESHOLD, velocity: Post.SWIPE_VELOCITY, direction: Hammer.DIRECTION_HORIZONTAL }]], inputClass: Hammer.TouchInput});
  $body.data("hammer", hammer);

  if (hasPrev) {
    hammer.on("swiperight", async function(e) {
      $("body").css({"transition-timing-function": "ease", "transition-duration": "0.2s", "opacity": "0", "transform": "translateX(150%)"});
      await Utility.delay(200);
      Post.swipe_prev(e);
    });
  }

  if (hasNext) {
    hammer.on("swipeleft", async function(e) {
      $("body").css({"transition-timing-function": "ease", "transition-duration": "0.2s", "opacity": "0", "transform": "translateX(-150%)"});
      await Utility.delay(200);
      Post.swipe_next(e);
    });
  }
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

  var $tag_string = $("#post_tag_string");
  $("#open-edit-dialog").hide();

  var dialog = $("<div/>").attr("id", "edit-dialog");
  $("#form").appendTo(dialog);
  dialog.dialog({
    title: "Edit tags",
    width: Post.EDIT_DIALOG_WIDTH,
    position: {
      my: "right",
      at: "right-20",
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
  $tag_string.focus().selectEnd().height($tag_string[0].scrollHeight);
}

Post.close_edit_dialog = function(e, ui) {
  $("#form").appendTo($("#c-posts #edit,#c-uploads #a-show"));
  $("#edit-dialog").remove();
  var $tag_string = $("#post_tag_string");
  $("div.input").has($tag_string).prevAll().show();
  $("#open-edit-dialog").show();
  $tag_string.css({"resize": "", "width": ""});
  $(document).trigger("danbooru:close-post-edit-dialog");
}

Post.swipe_prev = function(e) {
  if ($(".paginator a[rel~=prev]").length) {
    location.href = $("a[rel~=prev]").attr("href");
  }

  e.preventDefault();
}

Post.swipe_next = function(e) {
  if ($(".paginator a[rel~=next ]").length) {
    location.href = $(".paginator a[rel~=next]").attr("href");
  }

  e.preventDefault();
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
      $("#post_tag_string").focus().selectEnd().height($("#post_tag_string")[0].scrollHeight);
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
