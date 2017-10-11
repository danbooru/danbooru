(function() {
  Danbooru.Post = {};

  Danbooru.Post.pending_update_count = 0;

  Danbooru.Post.initialize_all = function() {
    this.initialize_post_previews();

    if ($("#c-posts").length) {
      this.initialize_shortcuts();
      this.initialize_saved_searches();
    }

    if ($("#c-posts").length && $("#a-index").length) {
      this.initialize_excerpt();
      this.initialize_gestures();
    }

    if ($("#c-posts").length && $("#a-show").length) {
      this.initialize_links();
      this.initialize_post_relationship_previews();
      this.initialize_favlist();
      this.initialize_post_sections();
      this.initialize_post_image_resize_links();
      this.initialize_post_image_resize_to_window_link();
      this.initialize_similar();
      this.initialize_replace_image_dialog();
      this.initialize_gestures();

      if ((Danbooru.meta("always-resize-images") === "true") || ((Danbooru.Cookie.get("dm") !== "1") && (window.screen.width <= 660))) {
        $("#image-resize-to-window-link").click();
      }
    }

    if ($("#image").length) {
      this.initialize_edit_dialog();
    }
  }

  Danbooru.Post.initialize_gestures = function() {
    var $body = $("body");
    if ($body.data("hammer")) {
      return;
    }

    if (!window.matchMedia) {
      return;
    }
    var mq = window.matchMedia('(max-width: 660px)');
    if (!mq.matches) {
      return;
    }
    var hasPrev = $("#a-show").length || $(".paginator a[rel~=prev]").length;
    var hasNext = $("#a-index").length && $(".paginator a[rel~=next]").length;

    $body.hammer({touchAction: 'auto', recognizers: [[Hammer.Swipe, { threshold: 20, velocity: 0.4, direction: Hammer.DIRECTION_HORIZONTAL }]]});

    if (hasPrev) {
      $body.hammer().bind("swiperight", function(e) {
        $("body").css({"transition-timing-function": "ease", "transition-duration": "0.3s", "opacity": "0", "transform": "translateX(150%)"});
        $.timeout(300).done(function() {Danbooru.Post.swipe_prev(e)});
      });
    }

    if (hasNext) {
      $body.hammer().bind("swipeleft", function(e) {
        $("body").css({"transition-timing-function": "ease", "transition-duration": "0.3s", "opacity": "0", "transform": "translateX(-150%)"});
        $.timeout(300).done(function() {Danbooru.Post.swipe_next(e)});
      });
    }
  }

  Danbooru.Post.initialize_edit_dialog = function(e) {
    $("#open-edit-dialog").button().show().click(function(e) {
      $(window).scrollTop($("#image").offset().top);
      Danbooru.Post.open_edit_dialog();
      e.preventDefault();
    });

    $("#toggle-related-tags-link").click(function(e) {
      Danbooru.RelatedTag.toggle();
      e.preventDefault();
    });
  }

  Danbooru.Post.open_edit_dialog = function() {
    var $tag_string = $("#post_tag_string,#upload_tag_string");
    $("div.input").has($tag_string).prevAll().hide();
    $("#open-edit-dialog").hide();

    $("#toggle-related-tags-link").show().click();

    var dialog = $("<div/>").attr("id", "edit-dialog");
    $("#form").appendTo(dialog);
    dialog.dialog({
      title: "Edit tags",
      width: $(window).width() * 0.6,
        position: {
          my: "right",
          at: "right-20",
          of: window
        },
      drag: function(e, ui) {
        if (Danbooru.meta("enable-auto-complete") === "true") {
          $tag_string.data("uiAutocomplete").close();
        }
      },
      close: Danbooru.Post.close_edit_dialog
    });
    dialog.dialog("widget").draggable("option", "containment", "none");

    var pin_button = $("<button/>").button({icons: {primary: "ui-icon-pin-w"}, label: "pin", text: false});
    pin_button.css({width: "20px", height: "20px", position: "absolute", right: "28.4px"});
    dialog.parent().children(".ui-dialog-titlebar").append(pin_button);
    pin_button.click(function(e) {
      var dialog_widget = $('.ui-dialog:has(#edit-dialog)');
      var pos = dialog_widget.offset();

      if (dialog_widget.css("position") === "absolute") {
        pos.left -= $(window).scrollLeft();
        pos.top -= $(window).scrollTop();
        dialog_widget.offset(pos).css({position:"fixed"});
        dialog.dialog("option", "resize", function() { dialog_widget.css({position:"fixed"}); });

        pin_button.button("option", "icons", {primary: "ui-icon-pin-s"});
      } else {
        pos.left += $(window).scrollLeft();
        pos.top += $(window).scrollTop();
        dialog_widget.offset(pos).css({position:"absolute"});
        dialog.dialog("option", "resize", function() {});

        pin_button.button("option", "icons", {primary: "ui-icon-pin-w"});
      }
    });

    dialog.parent().mouseout(function(e) {
      dialog.parent().css({"opacity": 0.6, "transition": "opacity .2s ease"});
    })
    .mouseover(function(e) {
      dialog.parent().css({"opacity": 1});
    });

    $tag_string.css({"resize": "none", "width": "100%"});
    $tag_string.focus().selectEnd().height($tag_string[0].scrollHeight);
  }

  Danbooru.Post.close_edit_dialog = function(e, ui) {
    $("#form").appendTo($("#c-posts #edit,#c-uploads #a-new"));
    $("#edit-dialog").remove();
    Danbooru.RelatedTag.show();
    $("#toggle-related-tags-link").hide();
    var $tag_string = $("#post_tag_string,#upload_tag_string");
    $("div.input").has($tag_string).prevAll().show();
    $("#open-edit-dialog").show();
    $tag_string.css({"resize": "", "width": ""});
  }

  Danbooru.Post.initialize_similar = function() {
    $("#similar-button").click(function(e) {
      $.post("/iqdb_queries", {"url": $("#post_source").val()}).done(function(html) {$("#iqdb-similar").html(html).show()});
      e.preventDefault();
    });
  }

  Danbooru.Post.swipe_prev = function(e) {
    if ($("#a-show").length) {
      window.history.back();
    } if ($(".paginator a[rel~=prev]").length) {
      location.href = $("a[rel~=prev]").attr("href");
    }

    e.preventDefault();
  }

  Danbooru.Post.nav_prev = function(e) {
    if ($("#search-seq-nav").length) {
      var href = $("#search-seq-nav a[rel~=prev]").attr("href");
      if (href) {
        location.href = href;
      }
    } else if ($(".paginator a[rel~=prev]").length) {
      location.href = $("a[rel~=prev]").attr("href");
    } else {
      var href = $("#pool-nav a.active[rel~=prev], #favgroup-nav a.active[rel~=prev]").attr("href");
      if (href) {
        location.href = href;
      }
    }

    e.preventDefault();
  }

  Danbooru.Post.nav_next = function(e) {
    if ($("#search-seq-nav").length) {
      var href = $("#search-seq-nav a[rel~=next]").attr("href");
      location.href = href;
    } else if ($(".paginator a[rel~=next]").length) {
      location.href = $(".paginator a[rel~=next]").attr("href");
    } else {
      var href = $("#pool-nav a.active[rel~=next], #favgroup-nav a.active[rel~=next]").attr("href");
      if (href) {
        location.href = href;
      }
    }

    e.preventDefault();
  }

  Danbooru.Post.swipe_next = function(e) {
    if ($(".paginator a[rel~=next]").length) {
      location.href = $(".paginator a[rel~=next]").attr("href");
    }

    e.preventDefault();
  }

  Danbooru.Post.initialize_shortcuts = function() {
    if ($("#a-show").length) {
      Danbooru.keydown("e", "edit", function(e) {
        $("#post-edit-link").trigger("click");
        $("#post_tag_string").focus();
        e.preventDefault();
      });

      if (Danbooru.meta("current-user-can-approve-posts") === "true") {
        Danbooru.keydown("shift+o", "approve", function(e) {
          $("#quick-mod-approve").click();
        });
      }

      Danbooru.keydown("a", "prev_page", Danbooru.Post.nav_prev);
      Danbooru.keydown("d", "next_page", Danbooru.Post.nav_next);
      Danbooru.keydown("f", "favorite", Danbooru.Post.favorite);
      Danbooru.keydown("shift+f", "unfavorite", Danbooru.Post.unfavorite);
    }
  }

  Danbooru.Post.initialize_links = function() {
    $("#copy-notes").click(function(e) {
      var current_post_id = $("meta[name=post-id]").attr("content");
      var other_post_id = parseInt(prompt("Enter the ID of the post to copy all notes to:"), 10);

      if (other_post_id !== null) {
        $.ajax("/posts/" + current_post_id + "/copy_notes", {
          type: "PUT",
          data: {
            other_post_id: other_post_id
          },
          success: function(data) {
            Danbooru.notice("Successfully copied notes to <a href='" + other_post_id + "'>post #" + other_post_id + "</a>");
          },
          error: function(data) {
            if (data.status === 404) {
              Danbooru.error("Error: Invalid destination post");
            } else if (data.responseJSON && data.responseJSON.reason) {
              Danbooru.error("Error: " + data.responseJSON.reason);
            } else {
              Danbooru.error("There was an error copying notes to <a href='" + other_post_id + "'>post #" + other_post_id + "</a>");
            }
          }
        });
      }

      e.preventDefault();
    });

    $(".unvote-post-link").hide();
  }

  Danbooru.Post.initialize_post_relationship_previews = function() {
    var current_post_id = $("meta[name=post-id]").attr("content");
    $("[id=post_" + current_post_id + "]").addClass("current-post");

    if (Danbooru.Cookie.get("show-relationship-previews") === "0") {
      this.toggle_relationship_preview($("#has-children-relationship-preview"), $("#has-children-relationship-preview-link"));
      this.toggle_relationship_preview($("#has-parent-relationship-preview"), $("#has-parent-relationship-preview-link"));
    }

    $("#has-children-relationship-preview-link").click(function(e) {
      Danbooru.Post.toggle_relationship_preview($("#has-children-relationship-preview"), $(this));
      e.preventDefault();
    });

    $("#has-parent-relationship-preview-link").click(function(e) {
      Danbooru.Post.toggle_relationship_preview($("#has-parent-relationship-preview"), $(this));
      e.preventDefault();
    });
  }

  Danbooru.Post.toggle_relationship_preview = function(preview, preview_link) {
    preview.toggle();
    if (preview.is(":visible")) {
      preview_link.html("&laquo; hide");
      Danbooru.Cookie.put("show-relationship-previews", "1");
    }
    else {
      preview_link.html("show &raquo;");
      Danbooru.Cookie.put("show-relationship-previews", "0");
    }
  }

  Danbooru.Post.initialize_favlist = function() {
    $("#favlist").hide();
    $("#hide-favlist-link").hide();
    var fav_count = $("#show-favlist-link").prev().text();
    if (fav_count === "0") {
      $("#show-favlist-link").hide();
    }

    $("#show-favlist-link").click(function(e) {
      $("#favlist").show();
      $(this).hide();
      $("#hide-favlist-link").show();
      e.preventDefault();
    });

    $("#hide-favlist-link").click(function(e) {
      $("#favlist").hide();
      $(this).hide();
      $("#show-favlist-link").show();
      e.preventDefault();
    });
  }

  Danbooru.Post.initialize_post_previews = function() {
    $(".post-preview").each(function(i, v) {
      Danbooru.Post.initialize_title_for(v);
    });
  }

  Danbooru.Post.initialize_title_for = function(post) {
    var $post = $(post);
    var $img = $post.find("img");
    var score = null;
    if ($post.data("views")) {
      score = " views:" + $post.data("views");
    } else {
      score = " score:" + $post.data("score");
    }
    $img.attr("title", $post.attr("data-tags") + " user:" + $post.attr("data-uploader").replace(/_/g, " ") + " rating:" + $post.data("rating") + score);
  }

  Danbooru.Post.expand_image = function(e) {
    var $link = $(e.target);
    var $image = $("#image");
    var $notice = $("#image-resize-notice");
    $image.attr("src", $link.attr("href"));
    $image.css("opacity", "0.25");
    $image.width($image.data("original-width"));
    $image.height($image.data("original-height"));        
    $image.on("load", function() {
      $image.css("opacity", "1");
      $notice.hide();
    });
    $notice.children().eq(0).hide();
    $notice.children().eq(1).show(); // Loading message
    Danbooru.Note.Box.scale_all();
    $image.data("scale-factor", 1);
    if ($("body").data("hammer")) {
      $("#image-container").css({overflow: "scroll"});
      $("body").data("hammer").set({enable: false});
    }
    e.preventDefault();
  }

  Danbooru.Post.initialize_post_image_resize_links = function() {
    $("#image-resize-link").click(Danbooru.Post.expand_image);

    if ($("#image-resize-notice").length) {
      Danbooru.keydown("v", "resize", function(e) {
        if ($("#image-resize-notice").is(":visible")) {
          $("#image-resize-link").click();
        } else {
          Danbooru.Post.expand_image(e);
        }
      });
    }
  }

  Danbooru.Post.resize_image_to_window = function($img) {
    if (($img.data("scale-factor") === 1) || ($img.data("scale-factor") === undefined)) {
      if ($(window).width() > 660) {
        var client_width = $(window).width() - $("#sidebar").width() - 75;
      } else {
        var client_width = $(window).width() - 2;
      }
      var client_height = $(window).height();

      if ($img.width() > client_width) {
        var ratio = client_width / $img.data("original-width");
        $img.data("scale-factor", ratio);
        $img.css("width", $img.data("original-width") * ratio);
        $img.css("height", $img.data("original-height") * ratio);
        Danbooru.Post.resize_ugoira_controls();
        if ($("body").data("hammer")) {
          $("#image-container").css({overflow: "visible"});
          $("body").data("hammer").set({enable: true});
        }
      }
    } else {
      $img.data("scale-factor", 1);
      $img.width($img.data("original-width"));
      $img.height($img.data("original-height"));
      Danbooru.Post.resize_ugoira_controls();
      if ($("body").data("hammer")) {
        $("#image-container").css({overflow: "scroll"});
        $("body").data("hammer").set({enable: false});
      }
    }

    Danbooru.Note.Box.scale_all();
  }

  Danbooru.Post.initialize_post_image_resize_to_window_link = function() {
    $("#image-resize-to-window-link").click(function(e) {
      Danbooru.Post.resize_image_to_window($("#image"));
      e.preventDefault();
    });
  }

  Danbooru.Post.initialize_excerpt = function() {
    $("#excerpt").hide();

    $("#show-posts-link").click(function(e) {
      $("#show-posts-link").parent("li").addClass("active");
      $("#show-excerpt-link").parent("li").removeClass("active");
      $("#posts").show();
      $("#excerpt").hide();
      e.preventDefault();
    });

    $("#show-excerpt-link").click(function(e) {
      if ($(this).parent("li").hasClass("active")) {
        return;
      }
      $("#show-posts-link").parent("li").removeClass("active");
      $("#show-excerpt-link").parent("li").addClass("active");
      $("#posts").hide();
      $("#excerpt").show();
      e.preventDefault();
    });

    if (!$(".post-preview").length && /Nobody here but us chickens/.test($("#posts").html())) {
      $("#show-excerpt-link").click();
    }
  }

  Danbooru.Post.initialize_post_sections = function() {
    $("#post-sections li a").click(function(e) {
      if (e.target.hash === "#comments") {
        $("#comments").show();
        $("#edit").hide();
        $("#share").hide();
      } else if (e.target.hash === "#edit") {
        $("#edit").show();
        $("#comments").hide();
        $("#share").hide();
        $("#post_tag_string").focus().selectEnd().height($("#post_tag_string")[0].scrollHeight);
        $("#related-tags-button").trigger("click");
        $("#find-artist-button").trigger("click");
      } else {
        $("#edit").hide();
        $("#comments").hide();
        $("#share").show();
        addthis.init();
      }

      $("#post-sections li").removeClass("active");
      $(e.target).parent("li").addClass("active");
      e.preventDefault();
    });

    $("#post-sections li:first-child").addClass("active");
    $("#notes").hide();
    $("#edit").hide();
  }

  Danbooru.Post.resize_ugoira_controls = function() {
    var $img = $("#image");
    var width = Math.max($img.width(), 350);
    $("#ugoira-control-panel").css("width", width);
    $("#seek-slider").css("width", width - 81);
  }

  Danbooru.Post.notice_update = function(x) {
    if (x === "inc") {
      Danbooru.Post.pending_update_count += 1;
      Danbooru.notice("Updating posts (" + Danbooru.Post.pending_update_count + " pending)...", true);
    } else {
      Danbooru.Post.pending_update_count -= 1;

      if (Danbooru.Post.pending_update_count < 1) {
        Danbooru.notice("Posts updated");
      } else {
        Danbooru.notice("Updating posts (" + Danbooru.Post.pending_update_count + " pending)...", true);
      }
    }
  }

  Danbooru.Post.update_data = function(data) {
    var $post = $("#post_" + data.id);
    $post.attr("data-tags", data.tag_string);
    $post.data("rating", data.rating);
    $post.removeClass("post-status-has-parent post-status-has-children");
    if (data.parent_id) {
      $post.addClass("post-status-has-parent");
    }
    if (data.has_visible_children) {
      $post.addClass("post-status-has-children");
    }
    Danbooru.Post.initialize_title_for($post);
  }

  Danbooru.Post.vote = function(score, id) {
    Danbooru.notice("Voting...");

    $.post("/posts/" + id + "/votes.js", {
       score: score
    });
  }

  Danbooru.Post.update = function(post_id, params) {
    Danbooru.Post.notice_update("inc");

    $.ajax({
      type: "PUT",
      url: "/posts/" + post_id + ".json",
      data: params,
      success: function(data) {
        Danbooru.Post.notice_update("dec");
        Danbooru.Post.update_data(data);
      },
      error: function(data) {
        Danbooru.Post.notice_update("dec");
        Danbooru.error('There was an error updating <a href="/posts/' + post_id + '">post #' + post_id + '</a>');
      }
    });
  }

  Danbooru.Post.ban = function(post_id) {
    $.ajax({
      type: "POST",
      url: "/moderator/post/posts/" + post_id + "/ban.js",
      data: {
        commit: "Ban"
      },
      success: function(data) {
        $("#post_" + post_id).remove();
      },
      error: function(data) {
        Danbooru.error('There was an error updating <a href="/posts/' + post_id + '">post #' + post_id + '</a>');
      }
    });
  }

  Danbooru.Post.approve = function(post_id) {
    $.post(
      "/moderator/post/approval.json",
      {"post_id": post_id}
    ).fail(function(data) {
      var message = $.map(data.responseJSON.errors, function(msg, attr) { return msg; }).join("; ");
      Danbooru.error("Error: " + message);
    }).done(function(data) {
      var $post = $("#post_" + post_id);
      if ($post.length) {
        $post.data("flags", $post.data("flags").replace(/pending/, ""));
        $post.removeClass("post-status-pending");
        Danbooru.notice("Approved post #" + post_id);
      }
    });
  }

  Danbooru.Post.favorite = function (e) {
    if ($("#add-to-favorites").is(":visible")) {
      $("#add-to-favorites").click();
    } else {
      if (Danbooru.meta("current-user-id") == "") {
        Danbooru.notice("You must be logged in to favorite posts");
      } else {
        Danbooru.notice("You have already favorited this post");
      }
    }
  };

  Danbooru.Post.unfavorite = function (e) {
    $.ajax("/favorites/" + Danbooru.meta("post-id") + ".js", {
      type: "DELETE"
    });
  };

  Danbooru.Post.initialize_saved_searches = function() {
    $("#saved_search_labels").autocomplete({
      source: function(req, resp) {
        Danbooru.SavedSearch.labels(req.term).success(function(labels) {
          resp(labels.map(function(label) {
            return {
              label: label.replace(/_/g, " "),
              value: label
            };
          }));
        });
      }
    });

    $("#save-search-dialog").dialog({
      width: 500,
      modal: true,
      autoOpen: false,
      buttons: {
        "Submit": function() {
          $("#save-search-dialog form").submit();
          $(this).dialog("close");
        },
        "Cancel": function() {
          $(this).dialog("close");
        }
      }
    });

    $("#save-search").click(function(e) {
      if (Danbooru.meta("disable-labeled-saved-searches") === "false") {
        $("#save-search-dialog").dialog("open");
      } else {
        $.post(
          "/saved_searches.js",
          {
            "saved_search_tags": $("#tags").attr("value")
          }
        );
      }

      e.preventDefault();
    });

    $("#search-dropdown #wiki-search").click(function(e) {
      window.location.href = "/wiki_pages?search%5Btitle%5D=" + encodeURIComponent($("#tags").val());
      e.preventDefault();
    });

    $("#search-dropdown #artist-search").click(function(e) {
      window.location.href = "/artists?search%5Bname%5D=" + encodeURIComponent($("#tags").val());
      e.preventDefault();
    });
  }

  Danbooru.Post.initialize_replace_image_dialog = function() {
    $("#replace-image-dialog").dialog({
      autoOpen: false,
      width: 700,
      modal: true,
      buttons: {
        "Submit": function() {
          $("#replace-image-dialog form").submit();
          $(this).dialog("close");
        },
        "Cancel": function() {
          $(this).dialog("close");
        }
      }
    });

    $('#replace-image-dialog form').submit(function() {
      $('#replace-image-dialog').dialog('close');
    });

    $("#replace-image").click(function(e) {
      e.preventDefault();
      $("#replace-image-dialog").dialog("open");
    });
  };
})();

$(document).ready(function() {
  Danbooru.Post.initialize_all();
});
